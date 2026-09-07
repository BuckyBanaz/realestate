import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/api/api_endpoints.dart';
import 'api_provider.dart';
import 'state_providers.dart';
import 'app_providers.dart';
import '../models/app_models.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

// ─── Shared secure storage provider ──────────────────────────────────────────
final storageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

// ─── Auth provider ────────────────────────────────────────────────────────────
final authProvider =
    AsyncNotifierProvider<AuthNotifier, String?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() async {
    try {
      final token = await ref.read(storageProvider).read(key: 'auth_token');
      dev.log(
        token != null
            ? '🔑 [AUTH] Cold start — token restored'
            : '🔑 [AUTH] Cold start — no stored token, showing login',
        name: 'AuthProvider',
      );
      if (token != null && token.isNotEmpty) {
        ref.read(apiClientProvider).setToken(token);
      }
      return token;
    } catch (e) {
      // FlutterSecureStorage can throw on corrupted keystore (Android factory reset, etc.)
      dev.log('⚠️ [AUTH] Failed to read token from storage: $e', name: 'AuthProvider');
      return null; // Treat as logged out — show login screen
    }
  }

  Future<bool> sendOtp(String phone) async {
    dev.log('📤 [SEND OTP] → phone: $phone', name: 'AuthProvider');
    try {
      // Dart-level timeout — independent of Dio, ensures the call always
      // returns even if the OS-level TLS handshake stalls on slow networks.
      final response = await ref.read(apiClientProvider).post(
        ApiEndpoints.sendOtp,
        data: {'mobile': phone},
      ).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.sendOtp),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out. Please check your internet.',
        ),
      );
      dev.log('✅ [SEND OTP] → status: ${response.statusCode}', name: 'AuthProvider');
      return true;
    } catch (e) {
      dev.log('❌ [SEND OTP] → FAILED: $e', name: 'AuthProvider', error: e);
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          dev.log('⚠️ Network timeout', name: 'AuthProvider');
        } else if (e.response?.statusCode == 422) {
          dev.log('⚠️ Invalid phone number', name: 'AuthProvider');
        } else if (e.response?.statusCode == 429) {
          dev.log('⚠️ Too many attempts', name: 'AuthProvider');
        }
      }
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    dev.log('📤 [VERIFY OTP] → phone: $phone  otp: $otp', name: 'AuthProvider');
    try {
      String? fcmToken;
      try {
        // Fix #7: Add timeout to FCM token fetch
        fcmToken = await FirebaseMessaging.instance.getToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            dev.log('⚠️ FCM token fetch timed out', name: 'Firebase');
            return '';
          },
        );
        dev.log('🔥 [FCM TOKEN]: $fcmToken', name: 'Firebase');
      } catch (e) {
        dev.log('⚠️ Failed to get FCM token: $e', name: 'Firebase');
      }

      final requestData = {
        'mobile': phone, 
        'otp': otp,
      };
      if (fcmToken != null && fcmToken.isNotEmpty) requestData['fcm_token'] = fcmToken;

      final response = await ref.read(apiClientProvider).post(
        ApiEndpoints.verifyOtp,
        data: requestData,
      ).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.verifyOtp),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out. Please check your internet.',
        ),
      );
      
      final data = response.data;
      final token = data['token'] ??
          data['access_token'] ??
          data['data']?['token'] ??
          data['data']?['access_token'];

      if (token != null) {
        final t = token.toString();
        ref.read(apiClientProvider).setToken(t);
        try {
          await ref.read(storageProvider).write(key: 'auth_token', value: t);
        } catch (e) {
          dev.log('⚠️ [AUTH] Failed to persist token: $e', name: 'AuthProvider');
          // Token set in memory — app works this session, re-login needed next cold start
        }
        state = AsyncData(t);
        return true;
      }
      return false;
    } catch (e) {
      dev.log('❌ [VERIFY OTP] → FAILED: $e', name: 'AuthProvider', error: e);
      return false;
    }
  }

  // Bug #7 fix: invalidate ALL data providers on logout so stale data
  // from the previous user never leaks into the next session.
  Future<void> logout() async {
    dev.log('🚪 [AUTH] Logging out...', name: 'AuthProvider');
    // Clear local state IMMEDIATELY — don't wait for server
    try {
      await ref.read(storageProvider).delete(key: 'auth_token');
    } catch (e) {
      dev.log('⚠️ [AUTH] Failed to delete token from storage: $e', name: 'AuthProvider');
    }
    ref.read(apiClientProvider).clearToken();
    state = const AsyncData(null);
    ref.invalidate(inventoryPageProvider);


    ref.invalidate(inventoryProvider);
    ref.invalidate(statsProvider);
    ref.invalidate(profileProvider);
    ref.invalidate(categoryFilterProvider);
    ref.invalidate(inventorySearchProvider);
    ref.invalidate(leadSearchProvider);
    ref.invalidate(inventoryFilterSeedProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(dealsProvider);
    ref.invalidate(commissionProvider);
    ref.invalidate(taskProvider);
    ref.invalidate(allPropertiesDropdownProvider);
    clearNameCache();

    dev.log('✅ [AUTH] Local state + token cleared', name: 'AuthProvider');
    // Fire-and-forget server logout — don't await, don't block UI
    ref.read(apiClientProvider).safePost(ApiEndpoints.logout).ignore();
  }
}
