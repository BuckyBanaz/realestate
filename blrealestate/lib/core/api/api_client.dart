import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

/// Singleton ApiClient — one Dio instance with in-memory token cache.
/// FIX #3: Token is cached in memory after the first read from Keystore.
/// Subsequent requests use the cached value — no Keystore IPC on every call.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  // In-memory token cache — read from Keystore only once, then kept here.
  // Cleared on logout via clearToken().
  String? _cachedToken;

  static const _storage = FlutterSecureStorage();

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        // Capture error response bodies for logging even on 4xx/5xx
        receiveDataWhenStatusError: true,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Token Interceptor — uses in-memory cache, falls back to Keystore only once.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Use in-memory cache first — avoids Keystore IPC on every request.
          // Falls back to Keystore only when cache is empty (cold start / after logout).
          if (!options.headers.containsKey('Authorization')) {
            _cachedToken ??= await _storage.read(key: 'auth_token');
            final token = _cachedToken;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // ── Comprehensive network error handling ────────────────────────────────
          // Each case provides a human-readable message instead of crashing.
          String message;
          switch (error.type) {
            case DioExceptionType.connectionTimeout:
              message = 'Connection timed out. Please check your internet.';
              break;
            case DioExceptionType.receiveTimeout:
              message = 'Server took too long to respond. Try again later.';
              break;
            case DioExceptionType.sendTimeout:
              message = 'Request timed out while sending data.';
              break;
            case DioExceptionType.connectionError:
              // Covers SocketException (no internet), DNS failures, etc.
              message = 'No internet connection. Please check your network.';
              break;
            case DioExceptionType.cancel:
              message = 'Request was cancelled.';
              break;
            case DioExceptionType.badResponse:
              if (error.response != null) {
                final data = error.response!.data;
                if (data is Map<String, dynamic>) {
                  message = data['message'] ?? data['error'] ?? 'An error occurred';
                } else {
                  message = 'Server error (${error.response!.statusCode})';
                }
              } else {
                message = 'An unexpected error occurred.';
              }
              break;
            default:
              message = error.message ?? 'An unexpected error occurred.';
          }
          dev.log('❌ [ApiClient] ${error.requestOptions.method} ${error.requestOptions.path} → $message', name: 'ApiClient');
          return handler.next(error.copyWith(message: message));
        },
      ),
    );

    // Logging — debug builds only, stripped in release
    assert(() {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
      return true;
    }());
  }

  /// Set token — stored in both memory cache and Dio default headers.
  /// Call this after login so every subsequent request uses the cached value.
  void setToken(String token) {
    _cachedToken = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear token from memory cache and Dio headers (called on logout).
  void clearToken() {
    _cachedToken = null;
    dio.options.headers.remove('Authorization');
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      dio.patch(path, data: data);

  Future<Response> postFormData(String path, {required FormData data}) =>
      dio.post(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );

  /// Like [postFormData] but with custom send/receive timeouts.
  /// Use this for file uploads where the default 15 s timeout is too short.
  Future<Response> postFormDataWithTimeout(
    String path, {
    required FormData data,
    Duration sendTimeout = const Duration(seconds: 60),
    Duration receiveTimeout = const Duration(seconds: 60),
  }) =>
      dio.post(
        path,
        data: data,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
        ),
      );

  // ── Safe wrappers — never throw, return null on any error ──────────────────
  // Use these in providers where a crash would freeze the whole UI.

  Future<Response?> safeGet(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      dev.log('⚠️ [ApiClient] safeGet failed for $path: $e', name: 'ApiClient');
      return null;
    }
  }

  Future<Response?> safePost(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } catch (e) {
      dev.log('⚠️ [ApiClient] safePost failed for $path: $e', name: 'ApiClient');
      return null;
    }
  }
}
