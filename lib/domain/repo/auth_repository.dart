import 'package:dio/dio.dart';
import 'package:realestate/domain/api/api_client.dart';
import 'package:realestate/domain/app/local_storage.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // Login Method
  Future<Map<String, dynamic>> login(String email, String password, {String? deviceToken}) async {
    try {
      final response = await _apiClient.dio.post(
        'login',
        data: {
          'email': email,
          'password': password,
          'device_token': "deviceToken",
        },
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        
        // Save Token & User Data
        await LocalStorage().saveToken(token);
        await LocalStorage().saveUser(data);
        
        return {
          'success': true,
          'message': response.data['message'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login Failed',
        };
      }
    } catch (e) {
      String errorMsg = 'An error occurred';
      if (e is DioException) {
        if (e.response != null) {
          errorMsg = e.response?.data['message'] ?? e.message;
        } else {
          errorMsg = e.message ?? 'Connection Error';
        }
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    }
  }

  // Register Method
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'register',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Registration Failed',
        };
      }
    } catch (e) {
      String errorMsg = 'An error occurred';
      if (e is DioException) {
        if (e.response != null) {
          errorMsg = e.response?.data['message'] ?? e.message;
        } else {
          errorMsg = e.message ?? 'Connection Error';
        }
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    }
  }

  Future<void> logout() async {
    await LocalStorage().clear();
  }
}
