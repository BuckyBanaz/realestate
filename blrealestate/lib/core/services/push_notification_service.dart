import 'dart:developer' as dev;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─── Local Notifications Setup ────────────────────────────────────────────────
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
  playSound: true,
);

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // ── 1. Request permissions ─────────────────────────────────────────────────
    // Wrapped: on some devices/OS versions, requestPermission() can throw.
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        dev.log('🔔 [FCM] Notifications Authorized', name: 'FCM');
      } else {
        dev.log('⚠️ [FCM] Notifications NOT Authorized', name: 'FCM');
      }
    } catch (e) {
      dev.log('❌ [FCM] requestPermission failed: $e', name: 'FCM');
    }

    // ── 2. Setup local notifications plugin ───────────────────────────────────
    // Wrapped: plugin initialization can fail if the drawable resource is missing.
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          dev.log('🔔 [FCM] Notification tapped: ${response.payload}', name: 'FCM');
        },
      );
    } catch (e) {
      dev.log('❌ [FCM] Local notifications init failed: $e', name: 'FCM');
    }

    // ── 3. Create Android notification channel ────────────────────────────────
    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    } catch (e) {
      dev.log('❌ [FCM] Notification channel creation failed: $e', name: 'FCM');
    }

    // ── 4. Force foreground notifications on Android ──────────────────────────
    try {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      dev.log('❌ [FCM] setForegroundNotificationPresentationOptions failed: $e', name: 'FCM');
    }

    // ── 5. Foreground: App is OPEN ────────────────────────────────────────────
    // Wrapped: the listener itself is safe, but individual message handling
    // may fail (e.g. bad payload). Errors here are caught inside _showLocalNotification.
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        dev.log('📩 [FCM] Foreground: ${message.notification?.title}', name: 'FCM');
        try {
          _showLocalNotification(message);
        } catch (e) {
          dev.log('❌ [FCM] _showLocalNotification failed: $e', name: 'FCM');
        }
      });
    } catch (e) {
      dev.log('❌ [FCM] onMessage listener setup failed: $e', name: 'FCM');
    }

    // ── 6. Background: App minimized, user taps notification ──────────────────
    try {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        dev.log('📩 [FCM] Opened from background: ${message.notification?.title}', name: 'FCM');
      });
    } catch (e) {
      dev.log('❌ [FCM] onMessageOpenedApp listener failed: $e', name: 'FCM');
    }

    // ── 7. Terminated: App was killed, user taps notification ─────────────────
    try {
      final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        dev.log('📩 [FCM] Launched from terminated: ${initialMessage.notification?.title}', name: 'FCM');
      }
    } catch (e) {
      dev.log('❌ [FCM] getInitialMessage failed: $e', name: 'FCM');
    }

    // ── 8. Log FCM token ──────────────────────────────────────────────────────
    try {
      final token = await getToken();
      dev.log('🔑 [FCM TOKEN]: $token', name: 'FCM');
    } catch (e) {
      dev.log('❌ [FCM] getToken failed: $e', name: 'FCM');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      dev.log('❌ [FCM] Failed to get token: $e', name: 'FCM');
      return null;
    }
  }
}
