import 'package:dio/dio.dart';
import 'package:realestate/domain/api/api_client.dart';
import 'package:realestate/data/models/home_data_model.dart';

class HomeRepository {
  final ApiClient _apiClient = ApiClient();

  Future<HomeDataModel?> fetchHomeData() async {
    try {
      final response = await _apiClient.dio.get('home-page');

      if (response.statusCode == 200 && response.data['status'] == true) {
        return HomeDataModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        print("HomeRepo Error: ${e.message}");
        if (e.response != null) {
          print("HomeRepo Error Data: ${e.response?.data}");
        }
      }
      return null;
    }
  }
}
