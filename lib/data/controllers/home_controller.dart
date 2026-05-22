import 'package:flutter/material.dart';
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

  // Advanced Filters
  var selectedFacing = "".obs;
  var isCornerPlot = false.obs;
  var selectedMinArea = 0.obs;
  
  // Use controllers for price fields to support clearing
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  
  var minPrice = "".obs;
  var maxPrice = "".obs;
  
  // Backwards compatibility for other views
  var selectedCategoryIndex = 0.obs;

  // Filtered Properties
  var filteredProperties = <PropertyListItem>[].obs;
  var isPropertiesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    minPriceController.addListener(() => minPrice.value = minPriceController.text.trim());
    maxPriceController.addListener(() => maxPrice.value = maxPriceController.text.trim());

    // Debounce to filter properties locally when price changes
    debounce(minPrice, (_) => fetchFilteredProperties(forceRefreshNetwork: false), time: const Duration(milliseconds: 300));
    debounce(maxPrice, (_) => fetchFilteredProperties(forceRefreshNetwork: false), time: const Duration(milliseconds: 300));
    
    _loadData();
    fetchCategories();
    fetchFilteredProperties();
  }

  @override
  void onClose() {
    super.onClose();
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
    
    // Clear advanced filters too
    selectedFacing.value = "";
    isCornerPlot.value = false;
    selectedMinArea.value = 0;
    minPrice.value = "";
    maxPrice.value = "";
    minPriceController.clear();
    maxPriceController.clear();
    
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

  List<PropertyListItem> _unfilteredProperties = [];

  Future<void> fetchFilteredProperties({bool forceRefreshNetwork = true}) async {
    if (forceRefreshNetwork || _unfilteredProperties.isEmpty) {
      isPropertiesLoading.value = true;
      final response = await _propertyRepo.searchProperties(
        categoryId: selectedCategory.value?.id,
        subCategoryId: selectedSubCategory.value?.id,
        subSubCategoryId: selectedSubSubCategory.value?.id,
        perPage: 50, // Get more results for filtered lists
      );
      if (response != null) {
        _unfilteredProperties = response.data;
      } else {
        _unfilteredProperties = [];
      }
    }

    var results = List<PropertyListItem>.from(_unfilteredProperties);
    
    // Advanced local filtering based on attributes and fields
    if (selectedFacing.isNotEmpty || isCornerPlot.value || selectedMinArea.value > 0 || minPrice.value.isNotEmpty || maxPrice.value.isNotEmpty) {
      results = results.where((p) {
        bool matches = true;

        // 1. Facing Filter
        if (selectedFacing.isNotEmpty) {
          final facingAttr = p.attributes.firstWhereOrNull((a) => a.attribute.toLowerCase() == "facing");
          if (facingAttr?.value?.toLowerCase() != selectedFacing.value.toLowerCase()) {
            matches = false;
          }
        }

        // 2. Corner Plot Filter
        if (matches && isCornerPlot.value) {
          final cornerAttr = p.attributes.firstWhereOrNull((a) => a.attribute.toLowerCase() == "corner plot");
          if (cornerAttr?.value?.toLowerCase() != "yes") {
            matches = false;
          }
        }

        // 3. Minimum Area Filter
        if (matches && selectedMinArea.value > 0) {
          // Parse area from string (e.g. "170sqyd" -> 170)
          final areaStr = p.area.toLowerCase().replaceAll(RegExp(r'[^0-9.]'), '');
          final areaVal = double.tryParse(areaStr) ?? 0.0;
          if (areaVal < selectedMinArea.value) {
            matches = false;
          }
        }

        // 4. Price Range Filter
        if (matches) {
          final priceStr = p.price.toLowerCase().replaceAll(RegExp(r'[^0-9.]'), '');
          final priceVal = double.tryParse(priceStr) ?? 0.0;
          if (minPrice.value.isNotEmpty) {
            final min = double.tryParse(minPrice.value) ?? 0.0;
            if (priceVal < min) matches = false;
          }
          if (matches && maxPrice.value.isNotEmpty) {
            final max = double.tryParse(maxPrice.value) ?? double.infinity;
            if (priceVal > max) matches = false;
          }
        }

        return matches;
      }).toList();
    }
    
    filteredProperties.assignAll(results);
    isPropertiesLoading.value = false;
  }

  void clearAllFilters() {
    selectedCategory.value = null;
    selectedSubCategory.value = null;
    selectedSubSubCategory.value = null;
    subCategories.clear();
    subSubCategories.clear();
    selectedFacing.value = "";
    isCornerPlot.value = false;
    selectedMinArea.value = 0;
    minPrice.value = "";
    maxPrice.value = "";
    minPriceController.clear();
    maxPriceController.clear();
    _unfilteredProperties.clear();
    fetchFilteredProperties();
  }

  void applyAdvancedFilters() {
    fetchFilteredProperties(forceRefreshNetwork: false);
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
