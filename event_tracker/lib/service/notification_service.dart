import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
    'event_tracker_default',
    'Event Tracker',
    description: 'General notifications for Event Tracker',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (kIsWeb) return; // Not supported on web

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    if (!kIsWeb && Platform.isAndroid) {
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_defaultChannel);
      // Request Android 13+ notifications permission
      try {
        await Permission.notification.request();
      } catch (_) {}
    }

    if (!kIsWeb && Platform.isIOS) {
      await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> showInviteNotification({required String title, required String body}) async {
    if (kIsWeb) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }

  Future<void> showCommentNotification({required String title, required String body}) async {
    if (kIsWeb) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }
}
