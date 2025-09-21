import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/api_constants.dart';
import '../controller/auth_controller.dart';
import '../model/event_comment_model.dart';
import '../model/event_invite_model.dart';

/// Connection status for WebSocket
enum ConnectionStatus { connecting, connected, disconnected }

/// A cross-platform WebSocket based real-time service with
/// auto-reconnect, heartbeat, and message fan-out streams.
class RealTimeService extends GetxService {
  // Env flag to enable/disable WS on web builds
  static const String _envEnableWsWeb = String.fromEnvironment('ENABLE_WS_WEB', defaultValue: 'true');
  bool get _wsWebEnabled => _envEnableWsWeb.toLowerCase() != 'false';
  static const String _envWsPath = String.fromEnvironment('WS_PATH', defaultValue: '/ws');

  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  Timer? _heartbeatTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription? _authLoginSub;
  StreamSubscription? _authTokenSub;
  int _reconnectAttempts = 0;
  DateTime? _webCooldownUntil;
  Timer? _connectConfirmTimer;
  bool _webWsDisabled = false; // runtime auto-disable for web if repeated failures

  /// Rx connection state
  final connectionStatus = ConnectionStatus.disconnected.obs;

  /// Broadcast streams for consumers
  final _commentStream = StreamController<EventComment>.broadcast();
  final _announcementStream = StreamController<EventComment>.broadcast();
  final _inviteStream = StreamController<EventInviteModel>.broadcast();

  Stream<EventComment> get comments$ => _commentStream.stream;
  Stream<EventComment> get announcements$ => _announcementStream.stream;
  Stream<EventInviteModel> get invites$ => _inviteStream.stream;

  /// Build the WebSocket URI from the REST API baseUrl
  Uri _buildWsUri({String? userId, String? token, bool secure = true}) {
    // ApiConstants.baseUrl example: https://localhost:7094/api
    final base = ApiConstants.baseUrl;
    final baseUri = Uri.parse(base);
    final scheme = secure ? 'wss' : 'ws';
    // Default ws path assumed '/ws' on the same host/port; override with WS_PATH
    final path = _envWsPath.isNotEmpty ? _envWsPath : '/ws';
    final queryParams = <String, String>{};
    if (token != null && token.isNotEmpty) queryParams['token'] = token;
    if (userId != null && userId.isNotEmpty) queryParams['userId'] = userId;
    return Uri(
      scheme: scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: path,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  Future<void> initialize() async {
    // If disabled for web (e.g. backend WS not ready), skip entirely
    if (kIsWeb && (!_wsWebEnabled || _webWsDisabled)) {
      return;
    }
    // Listen to connectivity to recover from offline state
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((results) {
          final hasNetwork = results.any((r) => r != ConnectivityResult.none);
          if (hasNetwork) {
            _ensureConnected();
          }
        });

    // React to auth state: connect on login, disconnect on logout
    final auth = Get.find<AuthController>();
    _authLoginSub = auth.isLoggedIn.listen((loggedIn) {
      if (loggedIn) {
        _ensureConnected();
      } else {
        disconnect();
      }
    });
    _authTokenSub = auth.token.listen((_) => _ensureConnected());

    // Attempt initial connect if already logged in
    if (auth.isLoggedIn.value) {
      await _connectInternal();
    }
  }

  Future<void> _ensureConnected() async {
    if (kIsWeb && (_webWsDisabled || (_webCooldownUntil != null && DateTime.now().isBefore(_webCooldownUntil!)))) {
      return; // respect cooldown to avoid noisy retries on web
    }
    if (connectionStatus.value == ConnectionStatus.connected) return;
    await _connectInternal();
  }

  Future<void> _connectInternal() async {
    if (_channel != null) return; // already connecting/connected
    if (kIsWeb && (_webWsDisabled || (_webCooldownUntil != null && DateTime.now().isBefore(_webCooldownUntil!)))) {
      return; // respect cooldown to avoid noisy retries on web
    }

    try {
      connectionStatus.value = ConnectionStatus.connecting;

      final auth = Get.find<AuthController>();
      final userId = auth.currentUser.value?.userId;
      final token = auth.token.value;
      // Determine if baseUrl is https to prefer secure ws
      final base = ApiConstants.baseUrl;
      final parsed = Uri.parse(base);
      final preferSecure = parsed.scheme == 'https';
      // Try secure first, then insecure fallback for dev/self-signed certs
      Uri uri = _buildWsUri(userId: userId, token: token, secure: preferSecure);
      try {
        // Helpful for diagnosing 200-handshake errors: verify this path on your backend
        // Example log: Connecting WebSocket to wss://host:port/ws?token=...&userId=...
        debugPrint('RealTimeService: Connecting WebSocket to ' + uri.toString());
      } catch (_) {}
      try {
        _channel = WebSocketChannel.connect(uri);
      } catch (_) {
        // Fallback to ws (insecure) for local/dev if secure failed
        uri = _buildWsUri(userId: userId, token: token, secure: false);
        try { debugPrint('RealTimeService: Fallback WS URI ' + uri.toString()); } catch (_) {}
        _channel = WebSocketChannel.connect(uri);
      }

      // Send hello/subscribe to help backends that require explicit subscription
      _sendJson({
        'type': 'hello',
        'subscribe': ['invites', 'comments', 'announcements'],
        'userId': userId,
        'token': token,
        'platform': GetPlatform.isWeb ? 'web' : (GetPlatform.isAndroid ? 'android' : 'ios'),
        'app': 'event-tracker'
      });

      // Start heartbeat (ping) every 20s
      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        _sendJson({ 'type': 'ping', 'ts': DateTime.now().toIso8601String() });
      });

      // Listen to messages
      _wsSubscription = _channel!.stream.listen(
        (event) {
          try {
            final data = _tryDecode(event);
            _handleMessage(data);
            // First valid message -> mark connected if still in connecting state
            if (connectionStatus.value == ConnectionStatus.connecting) {
              connectionStatus.value = ConnectionStatus.connected;
              _reconnectAttempts = 0;
              _webWsDisabled = false;
              _webCooldownUntil = null;
              _connectConfirmTimer?.cancel();
              _connectConfirmTimer = null;
            }
          } catch (e) {
            // ignore parse errors
          }
        },
        onDone: _handleSocketClosed,
        onError: (e, st) {
          _handleSocketClosed();
        },
        cancelOnError: true,
      );

      // Send an identify/subscribe message for backend (if supported)
      _sendJson({
        'type': 'identify',
        'userId': userId,
        'platform': GetPlatform.isWeb ? 'web' : (GetPlatform.isAndroid ? 'android' : 'ios'),
        'app': 'event-tracker'
      });

      // If server doesn't send a welcome message, assume connected after a short delay
      _connectConfirmTimer?.cancel();
      _connectConfirmTimer = Timer(const Duration(milliseconds: 1200), () {
        if (connectionStatus.value == ConnectionStatus.connecting && _channel != null) {
          connectionStatus.value = ConnectionStatus.connected;
          _reconnectAttempts = 0;
          _webWsDisabled = false;
          _webCooldownUntil = null;
        }
        _connectConfirmTimer?.cancel();
        _connectConfirmTimer = null;
      });
    } catch (e) {
      _reconnectAttempts++;
      if (kIsWeb) {
        // enter a short cooldown on web to suppress console spam
        final seconds = [15, 30, 45, 60][(_reconnectAttempts - 1).clamp(0, 3)];
        _webCooldownUntil = DateTime.now().add(Duration(seconds: seconds));
        if (_reconnectAttempts >= 3) {
          // After multiple failures, auto-disable WS for this session
          _webWsDisabled = true;
        }
      }
      await _scheduleReconnect();
    }
  }

  void _sendJson(Map<String, dynamic> jsonMap) {
    try {
      _channel?.sink.add(jsonEncode(jsonMap));
    } catch (_) {}
  }

  Map<String, dynamic> _tryDecode(dynamic event) {
    if (event is String) {
      return jsonDecode(event) as Map<String, dynamic>;
    }
    if (event is List<int>) {
      return jsonDecode(utf8.decode(event)) as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  void _handleMessage(Map<String, dynamic> data) {
    final type = (data['type']?.toString() ?? '').toLowerCase();
    switch (type) {
      case 'pong':
        // heartbeat response
        break;
      case 'comment_created':
      case 'announcement_created':
        final payload = data['comment'] ?? data['announcement'] ?? data['payload'] ?? {};
        final map = Map<String, dynamic>.from(payload as Map);
        final comment = EventComment.fromJson(map);
        if (type == 'comment_created') {
          _commentStream.add(comment);
        } else {
          _announcementStream.add(comment);
        }
        break;
      case 'invite_created':
      case 'invite_updated':
      case 'invitation_created':
      case 'invitation_updated':
      case 'event_invite_created':
      case 'event_invite_updated':
      case 'invitecreated':
      case 'inviteupdated': {
        final payload = data['invite'] ?? data['payload'] ?? data['data'] ?? {};
        try {
          final map = Map<String, dynamic>.from(payload as Map);
          final invite = EventInviteModel.fromJson(map);
          _inviteStream.add(invite);
        } catch (e) {
          // Fallback: try to build from top-level fields if payload missing
          try {
            final topMap = <String, dynamic>{
              'id': data['inviteId'] ?? data['id'] ?? data['Id'],
              'eventId': data['eventId'] ?? data['EventId'],
              'invitedUserId': data['invitedUserId'] ?? data['InvitedUserId'] ?? data['userId'] ?? data['UserId'],
              'status': data['status'] ?? data['Status'] ?? 'pending',
              'participantCount': data['participantCount'] ?? data['ParticipantCount'] ?? 1,
            }..removeWhere((k, v) => v == null);
            if (topMap.containsKey('eventId') && topMap.containsKey('invitedUserId')) {
              final invite = EventInviteModel.fromJson(topMap);
              _inviteStream.add(invite);
            }
          } catch (_) {}
        }
        break;
      }
      default:
        // Fallback: some servers send { type: 'invite', action: 'created'|'updated', invite: {...} }
        final action = (data['action']?.toString() ?? '').toLowerCase();
        final looksLikeInvite = type.contains('invite') || type.contains('invitation');
        // Try to parse when either the type indicates invite OR an 'invite' object is present
        final hasInviteObject = data['invite'] is Map || data['invitation'] is Map;
        if ((looksLikeInvite || hasInviteObject) && (action == 'created' || action == 'updated' || action.isEmpty)) {
          final payload = data['invite'] ?? data['invitation'] ?? data['payload'] ?? data['data'] ?? {};
          try {
            final map = Map<String, dynamic>.from(payload as Map);
            final invite = EventInviteModel.fromJson(map);
            _inviteStream.add(invite);
            break;
          } catch (_) {
            // Fallback to top-level mapping
            try {
              final topMap = <String, dynamic>{
                'id': data['inviteId'] ?? data['id'] ?? data['Id'],
                'eventId': data['eventId'] ?? data['EventId'],
                'invitedUserId': data['invitedUserId'] ?? data['InvitedUserId'] ?? data['userId'] ?? data['UserId'],
                'status': data['status'] ?? data['Status'] ?? 'pending',
                'participantCount': data['participantCount'] ?? data['ParticipantCount'] ?? 1,
              }..removeWhere((k, v) => v == null);
              if (topMap.containsKey('eventId') && topMap.containsKey('invitedUserId')) {
                final invite = EventInviteModel.fromJson(topMap);
                _inviteStream.add(invite);
                break;
              }
            } catch (_) {}
          }
        }
        // As a last resort, log the unrecognized type once in a while
        try {
          if (DateTime.now().second % 15 == 0) {
            debugPrint('RealTimeService: Unrecognized message type=' + (data['type']?.toString() ?? 'null'));
          }
        } catch (_) {}
        break;
    }
  }

  void _handleSocketClosed() {
    connectionStatus.value = ConnectionStatus.disconnected;
    _disposeSocket();
    _reconnectAttempts++;
    if (kIsWeb) {
      final seconds = [15, 30, 45, 60][(_reconnectAttempts - 1).clamp(0, 3)];
      _webCooldownUntil = DateTime.now().add(Duration(seconds: seconds));
      if (_reconnectAttempts >= 3) {
        _webWsDisabled = true;
      }
    }
    _scheduleReconnect();
  }

  Future<void> _scheduleReconnect() async {
    // Exponential backoff: 2,5,10,20,40,60s (then cap at 60s)
    final backoff = [2, 5, 10, 20, 40, 60];
    final idx = _reconnectAttempts.clamp(0, backoff.length - 1);
    final delaySec = backoff[idx];
    await Future.delayed(Duration(seconds: delaySec));
    if (connectionStatus.value == ConnectionStatus.connected) return;
    if (kIsWeb && _webWsDisabled) return; // stop trying on web if auto-disabled
    final results = await Connectivity().checkConnectivity();
    final hasNetwork = results.any((r) => r != ConnectivityResult.none);
    if (!hasNetwork) return; // wait for network
    try {
      await _connectInternal();
    } catch (_) {
      // swallow; next attempt will be scheduled on close or error
    }
  }

  void disconnect() {
    connectionStatus.value = ConnectionStatus.disconnected;
    _disposeSocket();
  }

  void _disposeSocket() {
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  @override
  void onClose() {
    _heartbeatTimer?.cancel();
    _wsSubscription?.cancel();
    _connectivitySub?.cancel();
    _authLoginSub?.cancel();
    _authTokenSub?.cancel();
    _commentStream.close();
    _announcementStream.close();
    _inviteStream.close();
    super.onClose();
  }
}
