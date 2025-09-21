import 'dart:async';
import '../utils/import_export.dart';

class InviteController extends GetxController {
  final InviteService _inviteService = InviteService();
  final EventInviteService _eventInviteService = EventInviteService();
  final RxList<UserModel> searchResults = <UserModel>[].obs;
  final RxList<EventInviteModel> eventInvites = <EventInviteModel>[].obs;
  final RxList<EventInviteModel> userInvites = <EventInviteModel>[].obs;
  final RxList<EventInviteModel> pendingInvites = <EventInviteModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;
  // When this increments, HomePage capacity cache is cleared and refreshed
  final RxInt capacityVersion = 0.obs;
  StreamSubscription<EventInviteModel>? _rtInviteSub;
  StreamSubscription? _rtConnSub;
  Timer? _fallbackTimer;
  int _fallbackTicks = 0;

  @override
  void onInit() {
    super.onInit();
    debounce(
      searchQuery,
      (_) => searchUsers(),
      time: const Duration(milliseconds: 500),
    );

    // Subscribe to real-time invites
    final rt = Get.find<RealTimeService>();
    _rtInviteSub = rt.invites$.listen((invite) async {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser == null) return;
      if (invite.invitedUserId != currentUser.userId) return;

      // Enrich invite if event data is missing
      EventInviteModel enriched = invite;
      if (invite.event == null) {
        try {
          final detailed = await _inviteService.getInviteDetails(invite.eventId, currentUser.userId);
          if (detailed != null) {
            enriched = detailed;
          }
        } catch (_) {}
      }

      // Update lists
      final idx = userInvites.indexWhere((i) => i.id == enriched.id);
      if (idx >= 0) {
        userInvites[idx] = enriched;
      } else {
        userInvites.add(enriched);
      }
      // Refresh pending list
      pendingInvites.value = userInvites.where((i) => i.status == InviteStatus.pending).toList();

      // If invite status affects capacity (e.g., accepted), refresh invited events and bump token
      if (enriched.status == InviteStatus.accepted) {
        unawaited(loadInvitedEvents(silent: true));
        capacityVersion.value++;
      }

      // Show notification (mobile) or in-app snackbar (web fallback)
      final title = 'New Event Invitation';
      final body = 'You are invited to ' + (enriched.event?.title ?? 'an event');
      try {
        await Get.find<NotificationService>().showInviteNotification(title: title, body: body);
      } catch (_) {}
      if (GetPlatform.isWeb) {
        ModernSnackbar.info(title: title, message: body);
      }
    });

    // On reconnect, reload invites to sync any missed updates
    _rtConnSub = rt.connectionStatus.listen((status) {
      if (status == ConnectionStatus.connected) {
        // Stop any HTTP fallback once real-time is active
        _fallbackTimer?.cancel();
        _fallbackTimer = null;
        _fallbackTicks = 0;
        loadUserInvites(silent: true);
        loadInvitedEvents(silent: true);
      } else if (status == ConnectionStatus.disconnected) {
        // If RT is unavailable (e.g., WS path misconfigured), start a gentle
        // background refresh to keep UI up-to-date without disruptive UI.
        _startFallbackRefreshIfNeeded();
      }
    });

    // If WS is not connected at startup (e.g., wrong WS path on web),
    // perform an immediate silent refresh and start fallback polling.
    if (rt.connectionStatus.value != ConnectionStatus.connected) {
      unawaited(loadUserInvites(silent: true));
      unawaited(loadInvitedEvents(silent: true));
      _startFallbackRefreshIfNeeded();
    }
  }

  @override
  void onClose() {
    _rtInviteSub?.cancel();
    _rtConnSub?.cancel();
    _fallbackTimer?.cancel();
    super.onClose();
  }

  void _startFallbackRefreshIfNeeded() {
    if (_fallbackTimer != null) return; // already running
    // Immediate refresh, then every 10s up to ~3 minutes (18 ticks) or until RT connects
    _fallbackTicks = 0;
    // Kick off one immediate silent refresh
    unawaited(loadUserInvites(silent: true));
    unawaited(loadInvitedEvents(silent: true));
    _fallbackTimer = Timer.periodic(const Duration(seconds: 5), (t) async {
      _fallbackTicks++;
      try {
        await loadUserInvites(silent: true);
        await loadInvitedEvents(silent: true);
      } catch (_) {}
      if (_fallbackTicks >= 24) {
        t.cancel();
        _fallbackTimer = null;
      }
    });
  }

  String? _extractErrorMessage(dynamic data) {
    try {
      if (data == null) return null;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data as Map);
        return map['message']?.toString() ?? map['error']?.toString();
      }
      return data.toString();
    } catch (_) {
      return null;
    }
  }

  // Search users by phone number
  Future<void> searchUsers() async {
    if (searchQuery.value.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    try {
      final raw = searchQuery.value.trim();
      final currentUser = Get.find<AuthController>().currentUser.value;

      List<String> candidates = _buildPhoneCandidates(raw, currentUser?.phone);
      final Map<String, UserModel> byId = {};

      for (final c in candidates) {
        try {
          final results = await _inviteService.searchUsersByPhone(c);
          for (final u in results) {
            if (currentUser == null || u.userId != currentUser.userId) {
              byId[u.userId] = u;
            }
          }
          // If we found any, we can stop early
          if (byId.isNotEmpty) break;
        } catch (_) {
          // Try next candidate silently
        }
      }
      searchResults.value = byId.values.toList();
    } catch (e) {
      ModernSnackbar.error(
        title: 'Search Failed',
        message: 'Failed to search users',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  List<String> _buildPhoneCandidates(String raw, String? currentUserPhone) {
    final t = raw.trim();
    final Set<String> out = <String>{};
    if (t.isEmpty) return [];

    final digits = _digitsOnly(t);
    // 1) Original as-is
    out.add(t);
    // 2) Digits-only
    if (digits.isNotEmpty) out.add(digits);
    // 3) Last 10 digits fallback (helps when DB stores national format)
    if (digits.length >= 10) out.add(digits.substring(digits.length - 10));
    // 4) If user phone has E.164, combine its country code with national digits
    if ((currentUserPhone ?? '').startsWith('+') && digits.length == 10) {
      final meDigits = _digitsOnly(currentUserPhone!);
      if (meDigits.length > 10) {
        final cc = meDigits.substring(0, meDigits.length - 10);
        out.add('+$cc$digits');
      }
    }
    return out.toList(growable: false);
  }

  // Create event invite
  Future<bool> createEventInvite(String eventId, String userId) async {
    return createEventInviteWithParticipants(eventId, userId, 1);
  }

  // Create event invite with participant count
  Future<bool> createEventInviteWithParticipants(String eventId, String userId, int participantCount) async {
    try {
      // First check if user is already invited
      final existing = await _inviteService.getInviteDetails(eventId, userId);
      if (existing != null) {
        if (existing.isAccepted) {
          ModernSnackbar.error(
            title: 'Already Invited',
            message: 'User is already a member of this event',
          );
        } else if (existing.isPending) {
          ModernSnackbar.error(
            title: 'Already Invited',
            message: 'User already has a pending invitation',
          );
        } else if (existing.isDeclined) {
          // If declined, create a new invite
          await _inviteService.deleteInvite(existing.id);
        }
        return false;
      }

      // Check event capacity before creating invite
      try {
        final capacityInfo = await Get.find<EventService>().getEventCapacityInfo(eventId);
        final maxCapacity = (capacityInfo['maxCapacity'] as int?) ?? 0;
        // If maxCapacity == 0, treat as unlimited and skip pre-check
        if (maxCapacity > 0) {
          final availableSpaces = (capacityInfo['availableSpaces'] as int?) ?? 0;
          if (availableSpaces < participantCount) {
            ModernSnackbar.error(
              title: 'Capacity Exceeded',
              message: 'Only $availableSpaces spaces available. Cannot invite $participantCount participants.',
            );
            return false;
          }
        }
      } catch (e) {
        print('Error checking capacity: $e');
        // Continue with invite creation if capacity check fails
      }

      final invite = EventInviteModel(
        id: const Uuid().v4(),
        eventId: eventId,
        invitedUserId: userId,
        status: InviteStatus.pending,
        participantCount: participantCount,
        createdAt: DateTime.now(),
      );

      final success = await _inviteService.createEventInvite(invite);
      
      if (success) {
        // Success snackbar suppressed to avoid noisy popups
        await loadEventInvites(eventId);
        // Pending invites don't change capacity; no bump required here
      }
      
      return success;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to send invitation';
      ModernSnackbar.error(
        title: 'Invite Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Invite Failed',
        message: 'Failed to send invitation',
      );
      return false;
    }
  }

  // Load invites for a specific event (for EventInvitesPage)
  Future<void> loadEventInvites(String eventId) async {
    isLoading.value = true;
    try {
      final invites = await _eventInviteService.getEventInvitesByEventId(eventId);
      eventInvites.value = invites;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to load user invites';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load user invites',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load invites for current user
  Future<void> loadUserInvites({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        print('Loading invites for user: ${currentUser.userId}');
        
        // Load all user invites
        final allInvites = await _inviteService.getUserInvites(currentUser.userId);
        print('Loaded ${allInvites.length} user invites');
        userInvites.value = allInvites;
        // Compute pending from the loaded list to avoid extra API & errors
        final computedPending = allInvites.where((i) => i.status == InviteStatus.pending).toList();
        print('Computed ${computedPending.length} pending invites');
        pendingInvites.value = computedPending;
        
        print('User invites loaded successfully');
      } else {
        print('No current user found');
      }
    } on DioException catch (e) {
      print('DioException loading user invites: ${e.response?.statusCode} - ${e.response?.data}');
      final errorMessage = _extractErrorMessage(e.response?.data) ?? 'Failed to load your invitations';
      if (!silent) {
        ModernSnackbar.error(
          title: 'Loading Failed',
          message: errorMessage,
        );
      } else {
        // Silent mode: don't disrupt UI with snackbars
      }
    } catch (e) {
      print('Error loading user invites: $e');
      if (!silent) {
        ModernSnackbar.error(
          title: 'Loading Failed',
          message: 'Failed to load your invitations',
        );
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  // Update invite status
  Future<bool> updateInviteStatus(String inviteId, InviteStatus status) async {
    try {
      final success = await _inviteService.updateInviteStatus(inviteId, status.value);
      
      if (success) {
        await loadUserInvites();
        // Capacity may change if status becomes accepted or cancelled
        if (status != InviteStatus.pending) capacityVersion.value++;
        // Success snackbar suppressed to avoid noisy popups
      }
      
      return success;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to update invite status';
      ModernSnackbar.error(
        title: 'Update Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Update Failed',
        message: 'Failed to update invite status',
      );
      return false;
    }
  }

  // Update invite status with participant count
  Future<bool> updateInviteStatusWithParticipants(String inviteId, InviteStatus status, int participantCount) async {
    try {
      final success = await _inviteService.updateInviteStatusWithParticipants(inviteId, status.value, participantCount);
      
      if (success) {
        await loadUserInvites();
        if (status != InviteStatus.pending) capacityVersion.value++;
        // Success snackbar suppressed to avoid noisy popups
      }
      
      return success;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to update invite';
      ModernSnackbar.error(
        title: 'Update Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Update Failed',
        message: 'Failed to update invite',
      );
      return false;
    }
  }

  // Check if user is invited to event
  Future<bool> isUserInvitedToEvent(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        final invites = await _inviteService.getUserInvites(currentUser.userId);
        return invites.any((invite) => invite.eventId == eventId);
      }
      return false;
    } on DioException {
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get invite details for current user
  Future<EventInviteModel?> getInviteDetails(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        return await _inviteService.getInviteDetails(eventId, currentUser.userId);
      }
      return null;
    } on DioException catch (e) {
      ModernSnackbar.error(
        title: 'Error',
        message: e.response?.data['message'] ?? 'Failed to get invite details',
      );
      return null;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Error',
        message: 'Failed to get invite details',
      );
      return null;
    }
  }

  // Delete invite
  Future<bool> deleteInvite(String inviteId) async {
    try {
      final success = await _inviteService.deleteInvite(inviteId);
      
      if (success) {
        await loadUserInvites();
        capacityVersion.value++;
        // Success snackbar suppressed to avoid noisy popups
      }
      
      return success;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data) ?? 'Failed to delete invite';
      ModernSnackbar.error(
        title: 'Delete Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Delete Failed',
        message: 'Failed to delete invite',
      );
      return false;
    }
  }

  // Get filtered invites based on status
  List<EventInviteModel> getFilteredInvites() {
    if (selectedStatus.value == 'all') {
      return userInvites;
    }
    final filterStatus = InviteStatusExtension.fromString(selectedStatus.value);
    return userInvites.where((invite) => invite.status == filterStatus).toList();
  }

  // Load events that user is invited to (for home page)
  final RxList<Map<String, dynamic>> invitedEvents = <Map<String, dynamic>>[].obs;
  final RxList<Event> acceptedEvents = <Event>[].obs;
  final RxList<EventInviteModel> acceptedEventInvites = <EventInviteModel>[].obs;

  Future<void> loadInvitedEvents({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        // Get all events user is invited to
        final events = await _inviteService.getEventsUserIsInvitedTo(currentUser.userId);
        invitedEvents.value = events;

        // Update the accepted events list
        acceptedEvents.value = events
          .where((e) => e['invite'] != null && 
            e['invite'].status == InviteStatus.accepted)
          .map((e) => e['event'] as Event)
          .toList();
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data) ?? 'Failed to load invited events';
      if (!silent) {
        ModernSnackbar.error(
          title: 'Loading Failed',
          message: errorMessage,
        );
      }
    } catch (e) {
      if (!silent) {
        ModernSnackbar.error(
          title: 'Loading Failed',
          message: 'Failed to load invited events',
        );
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  // Load accepted invites for a specific event
  Future<void> loadAcceptedEventInvites(String eventId) async {
    isLoading.value = true;
    try {
      print('Loading accepted invites for event: $eventId');
      final invites = await _inviteService.getAcceptedInvitesForEvent(eventId);
      acceptedEventInvites.value = invites;
      print('Loaded ${invites.length} accepted invites');
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to load accepted invites';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      print('Error loading accepted invites: $e');
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load accepted invites',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear search results
  void clearSearch() {
    searchResults.clear();
    searchQuery.value = '';
  }
} 