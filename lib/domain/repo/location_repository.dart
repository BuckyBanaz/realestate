import 'package:dio/dio.dart';
import 'package:realestate/domain/api/api_client.dart';
import 'package:realestate/data/models/location_details_model.dart';

class LocationRepository {
  final ApiClient _apiClient = ApiClient();

  Future<LocationDetailsModel?> fetchLocationProperties(int addressId) async {
    try {
      final response = await _apiClient.dio.get('properties/address/$addressId');

      if (response.statusCode == 200 && response.data['status'] == true) {
        return LocationDetailsModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        print("LocationRepo Error: ${e.message}");
        if (e.response != null) {
          print("LocationRepo Error Response: ${e.response?.data}");
        }
        if (e.type == DioExceptionType.connectionTimeout) {
          print("LocationRepo Error: Connection Timeout. Check your network or server URL.");
        }
      }
      return null;
    }
  }
}
