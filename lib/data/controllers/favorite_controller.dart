import 'package:get/get.dart';
import 'package:realestate/data/models/favorite_model.dart';
import 'package:realestate/domain/repo/property_repository.dart';

class FavoriteController extends GetxController {
  final PropertyRepository _repository = PropertyRepository();
  
  var isLoading = false.obs;
  var favorites = <FavoriteProperty>[].obs;
  var total = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      isLoading.value = true;
      final response = await _repository.fetchFavorites();
      
      if (response != null && response.status) {
        favorites.value = response.data;
        total.value = response.total;
      }
    } catch (e) {
      print('Error fetching favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshFavorites() async {
    await fetchFavorites();
  }
}
