import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../firebase_options.dart';
import 'local_storage.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static const String _androidChannelId = 'high_importance_channel';
  static const String _androidChannelName = 'High Importance Notifications';
  static const String _androidChannelDescription =
      'Used for important notifications with sound.';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _localNotificationsInitialized = false;

  Future<void> init() async {
    if (!kIsWeb) {
      await _initLocalNotifications();
      _listenForForegroundMessages();
    }
    await _requestPermission();
    await _syncToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await LocalStorage().saveFcmToken(token);
      debugPrint('FCM token refreshed');
    });
  }

  Future<void> _requestPermission() async {
    // App open par notification permission request
    final status = await Permission.notification.request();
    debugPrint('Notification permission: $status');

    // iOS/APNs ke liye FCM permission bhi request karna safe hai
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    if (_localNotificationsInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.high,
        playSound: true,
      );
      await androidPlugin.createNotificationChannel(channel);
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _localNotificationsInitialized = true;
  }

  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) async {
      await showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    if (kIsWeb) return;
    await _ensureLocalNotificationsInitialized();

    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: notification?.android?.smallIcon ?? '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (!_localNotificationsInitialized) {
      await _initLocalNotifications();
    }
  }

  Future<void> _syncToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await LocalStorage().saveFcmToken(token);
        debugPrint('FCM token saved');
      }
    } catch (e) {
      debugPrint('FCM token fetch failed: $e');
    }
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    if (kIsWeb) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().showNotification(message);
  }
}
