import 'package:get/get.dart';
import 'package:realestate/domain/repo/home_repository.dart';
import 'package:realestate/data/models/home_data_model.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepo = HomeRepository();

  // Observables
  var isRefreshing = false.obs;
  var isLoading = true.obs;
  
  // Data Observables
  var categoriesWithProperties = <CategoryWithProperties>[].obs;
  var topLocations = <TopLocation>[].obs;
  var newsList = <NewsItem>[].obs;
  
  // UI State
  var selectedCategoryIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    final data = await _homeRepo.fetchHomeData();
    if (data != null) {
      categoriesWithProperties.value = data.categories;
      topLocations.value = data.topLocations;
      newsList.value = data.news;
    }
    isLoading.value = false;
  }

  // Refresh Method
  Future<void> onRefresh() async {
    print("Home Controller: Refreshing data...");
    isRefreshing.value = true;
    isLoading.value = true; // Trigger shimmers
    
    // Optional: Reset selection on refresh
    selectedCategoryIndex.value = 0;
    
    // Add a small delay so the shimmer is actually visible to the user
    await Future.delayed(const Duration(seconds: 1));
    
    final data = await _homeRepo.fetchHomeData();
    if (data != null) {
      print("Home Controller: Data fetched successfully");
      categoriesWithProperties.value = data.categories;
      topLocations.value = data.topLocations;
      newsList.value = data.news;
    } else {
      print("Home Controller: Data fetch failed");
    }
    
    isLoading.value = false;
    isRefreshing.value = false;
  }
}
