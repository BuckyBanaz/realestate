import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:realestate/domain/app/local_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://108.181.185.27/blapis/api/'; // Updated base URL

  late Dio _dio;
  
  // Singleton
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ANSI Color Constants
    const String reset = '\x1B[0m';
    const String red = '\x1B[31m';
    const String green = '\x1B[32m';
    const String yellow = '\x1B[33m';
    const String blue = '\x1B[34m';
    const String cyan = '\x1B[36m';
    const String white = '\x1B[37m';

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add Token if available
          final token = LocalStorage().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          debugPrint('$blue--> [${options.method}] $cyan${options.uri}$reset');
          if (options.data != null) {
            debugPrint('$yellow Body: ${options.data}$reset');
          }
          if (options.queryParameters.isNotEmpty) {
             debugPrint('$yellow Query Params: ${options.queryParameters}$reset');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('$green<-- [${response.statusCode}] $cyan${response.requestOptions.uri}$reset');
          
          // Pretty print response data if possible (simplified here)
          debugPrint('$green Response: ${response.data}$reset');
          
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('$red<-- Error [${e.response?.statusCode}] $cyan${e.requestOptions.uri}$reset');
          debugPrint('$red Message: ${e.message}$reset');
          if (e.response != null) {
             debugPrint('$red Error Data: ${e.response?.data}$reset');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
