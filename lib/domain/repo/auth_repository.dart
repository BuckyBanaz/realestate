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
      return {
        'success': false,
        'message': _handleError(e),
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

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['status'] == true) {
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
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  // Update Profile Method
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? password,
    String? imagePath,
  }) async {
    try {
      Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'phone': phone,
      };

      if (address != null) data['address'] = address;
      if (password != null && password.isNotEmpty) data['password'] = password;

      if (imagePath != null && imagePath.isNotEmpty) {
        data['profile_image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
      }

      final formData = FormData.fromMap(data);

      final response = await _apiClient.dio.post(
        'profile/update',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final userData = response.data['data'];
        // Update local user data
        await LocalStorage().saveUser(userData);
        
        return {
          'success': true,
          'message': response.data['message'],
          'data': userData,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Update Failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  Future<void> logout() async {
    await LocalStorage().clear();
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiClient.dio.post(
        'forgot-password',
        data: {'email': email},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'reset-password',
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
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
          'message': response.data['message'] ?? 'Password reset failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          // Check for validation errors first (e.g., email already taken)
          if (data.containsKey('errors') && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              List<String> allErrors = [];
              errors.forEach((key, value) {
                if (value is List && value.isNotEmpty) {
                  allErrors.add(value.first.toString());
                } else {
                  allErrors.add(value.toString());
                }
              });
              return allErrors.join("\n");
            }
          }
          // Check for a general message
          if (data.containsKey('message') && data['message'] != null) {
            return data['message'].toString();
          }
        }
      }
      return "Something went wrong. Please try again.";
    }
    return "An unexpected error occurred.";
  }
}
