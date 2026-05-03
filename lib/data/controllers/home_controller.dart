import 'package:get/get.dart';
import 'package:realestate/domain/repo/home_repository.dart';
import 'package:realestate/data/models/home_data_model.dart';
import 'package:realestate/data/models/category_filter_model.dart';
import 'package:realestate/data/models/property_list_model.dart';
import 'package:realestate/domain/repo/property_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepo = HomeRepository();
  final PropertyRepository _propertyRepo = PropertyRepository();

  // Observables
  var isRefreshing = false.obs;
  var isLoading = true.obs;
  
  // Data Observables
  var categoriesWithProperties = <CategoryWithProperties>[].obs;
  var topLocations = <TopLocation>[].obs;
  var newsList = <NewsItem>[].obs;
  
  // Hierarchical Filter State
  var categories = <CategoryFilter>[].obs;
  var subCategories = <CategoryFilter>[].obs;
  var subSubCategories = <CategoryFilter>[].obs;

  var selectedCategory = Rxn<CategoryFilter>();
  var selectedSubCategory = Rxn<CategoryFilter>();
  var selectedSubSubCategory = Rxn<CategoryFilter>();
  
  // Backwards compatibility for other views
  var selectedCategoryIndex = 0.obs;

  // Filtered Properties
  var filteredProperties = <PropertyListItem>[].obs;
  var isPropertiesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    fetchCategories();
    fetchFilteredProperties();
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

  Future<void> onRefresh() async {
    print("Home Controller: Refreshing data...");
    isRefreshing.value = true;
    
    selectedCategory.value = null;
    selectedSubCategory.value = null;
    selectedSubSubCategory.value = null;
    subCategories.clear();
    subSubCategories.clear();
    selectedCategoryIndex.value = 0;
    
    await Future.wait([
      _loadData(),
      fetchCategories(),
      fetchFilteredProperties(),
    ]);
    
    isRefreshing.value = false;
  }

  Future<void> fetchCategories() async {
    final result = await _propertyRepo.fetchCategories();
    categories.assignAll(result);
  }

  Future<void> fetchFilteredProperties() async {
    isPropertiesLoading.value = true;
    final response = await _propertyRepo.searchProperties(
      categoryId: selectedCategory.value?.id,
      subCategoryId: selectedSubCategory.value?.id,
      subSubCategoryId: selectedSubSubCategory.value?.id,
    );
    if (response != null) {
      filteredProperties.assignAll(response.data);
    }
    isPropertiesLoading.value = false;
  }

  void onCategorySelected(CategoryFilter? category) {
    selectedCategory.value = category;
    selectedSubCategory.value = null;
    selectedSubSubCategory.value = null;
    
    if (category != null) {
      subCategories.assignAll(category.children);
    } else {
      subCategories.clear();
    }
    subSubCategories.clear();
    fetchFilteredProperties();
  }

  void onSubCategorySelected(CategoryFilter? subCategory) {
    selectedSubCategory.value = subCategory;
    selectedSubSubCategory.value = null;

    if (subCategory != null) {
      subSubCategories.assignAll(subCategory.children);
    } else {
      subSubCategories.clear();
    }
    fetchFilteredProperties();
  }

  void onSubSubCategorySelected(CategoryFilter? subSubCategory) {
    selectedSubSubCategory.value = subSubCategory;
    fetchFilteredProperties();
  }
}
