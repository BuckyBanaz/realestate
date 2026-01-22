import 'package:dio/dio.dart';
import 'package:realestate/domain/api/api_client.dart';
import 'package:realestate/data/models/resources_model.dart';

class ResourcesRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ResourcesResponse?> fetchResources() async {
    try {
      final response = await _apiClient.dio.get('resources');
      if (response.statusCode == 200) {
        return ResourcesResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        print("ResourcesRepo Error: ${e.message}");
        if (e.response != null) {
          print("ResourcesRepo Error Response: ${e.response?.data}");
        }
      }
      return null;
    }
  }
}
