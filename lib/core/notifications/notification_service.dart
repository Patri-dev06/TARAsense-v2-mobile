import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Must be a top-level function — runs in a separate isolate when app is killed.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Android displays the notification automatically from the FCM payload.
  // No extra work needed here for basic notification display.
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // Channel ID must match the value in AndroidManifest.xml meta-data.
  static const String _channelId = 'tarasense_studies';
  static const String _channelName = 'New Studies';
  static const String _channelDesc =
      'Alerts when new consumer studies are posted';

  Future<void> initialize() async {
    // Register the handler that runs when a message arrives while app is killed.
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Ask the user for notification permission (Android 13+ requires this).
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Set up flutter_local_notifications — needed to show a heads-up banner
    // when the app is open (FCM doesn't show UI automatically in foreground).
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Create the notification channel on Android 8+.
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    // Show a local notification banner when the app is open and a message arrives.
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  /// The unique token that identifies this device to FCM.
  /// Send this to the backend so it knows where to deliver notifications.
  Future<String?> getToken() => _fcm.getToken();

  /// FCM occasionally rotates the token. Subscribe to this to re-register.
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  /// Fires when the user taps a notification while the app is in the background
  /// (but not fully killed).
  Stream<RemoteMessage> get onNotificationTap =>
      FirebaseMessaging.onMessageOpenedApp;

  /// If the app was launched by tapping a notification (from killed state),
  /// this returns that notification. Call once on startup.
  Future<RemoteMessage?> getInitialMessage() => _fcm.getInitialMessage();

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: notification.android?.smallIcon,
        ),
      ),
    );
  }
}
