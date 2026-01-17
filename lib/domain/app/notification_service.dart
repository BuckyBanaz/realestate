import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'local_storage.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
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
}
