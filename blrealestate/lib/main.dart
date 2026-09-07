import 'dart:async';
import 'dart:developer' as dev;
import 'package:blrealestate/core/constants/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'providers/theme_provider.dart';
import 'splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/push_notification_service.dart';
import 'firebase_options.dart';

// ADB dev commands (do not remove):
// & "C:\Users\HP\AppData\Local\Android\Sdk\platform-tools\adb.exe" uninstall com.blrealestateapp.blrealestate
// adb kill-server
// adb start-server
// adb devices
// adb tcpip 5555

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Guard against duplicate-app — background isolate may run after main isolate
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ── Cap Flutter's in-memory image cache ─────────────────────────────────
    // 40MB for 1-2GB RAM devices. Prevents OOM kills.
    PaintingBinding.instance.imageCache.maximumSizeBytes = 40 * 1024 * 1024;
    PaintingBinding.instance.imageCache.maximumSize = 80;

    // ── Pre-warm FlutterSecureStorage before first frame ────────────────────
    // Completes RSA→AES-GCM migration before the splash renders,
    // eliminating the 98-frame skip on first install.
    try {
      await const FlutterSecureStorage().read(key: '__warmup__');
    } catch (_) {}

    // ── Firebase ────────────────────────────────────────────────────────────
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e, stack) {
      dev.log('❌ [Firebase] Init failed: $e', name: 'Startup', error: e, stackTrace: stack);
    }

    // ── Global error handlers ───────────────────────────────────────────────
    FlutterError.onError = (FlutterErrorDetails details) {
      dev.log('❌ [FlutterError] ${details.exceptionAsString()}',
          name: 'GlobalErrorHandler', error: details.exception, stackTrace: details.stack);
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordFlutterError(details, fatal: false);
      }
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      dev.log('❌ [PlatformDispatcher] $error',
          name: 'GlobalErrorHandler', error: error, stackTrace: stack);
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
      }
      return true;
    };

    // Debug: show red screen. Release: silent grey box.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      dev.log('❌ [ErrorWidget] ${details.exceptionAsString()}', name: 'GlobalErrorHandler');
      if (kDebugMode) return ErrorWidget(details.exception);
      return const SizedBox.shrink();
    };

    // ── Push Notifications ──────────────────────────────────────────────────
    try {
      PushNotificationService().initialize();
    } catch (e, stack) {
      dev.log('❌ [PushNotification] Init failed: $e', name: 'Startup', error: e, stackTrace: stack);
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    runApp(const ProviderScope(child: BLRealEstateApp()));
  }, (error, stack) {
    dev.log('❌ [ZoneError] $error', name: 'GlobalErrorHandler', error: error, stackTrace: stack);
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    }
  });
}

class BLRealEstateApp extends ConsumerWidget {
  const BLRealEstateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref
        .watch(themeProvider)
        .maybeWhen(data: (mode) => mode, orElse: () => ThemeMode.light);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
