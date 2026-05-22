import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realestate/data/models/property_list_model.dart';
import 'package:realestate/domain/repo/property_repository.dart';
import 'package:realestate/data/models/category_filter_model.dart';

class PropertySearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final PropertyRepository _repository = PropertyRepository();
  
  var searchQuery = "".obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var searchResults = <PropertyListItem>[].obs;
  
  // Hierarchical Filter State
  var categories = <CategoryFilter>[].obs;
  var subCategories = <CategoryFilter>[].obs;
  var subSubCategories = <CategoryFilter>[].obs;

  var selectedCategory = Rxn<CategoryFilter>();
  var selectedSubCategory = Rxn<CategoryFilter>();
  var selectedSubSubCategory = Rxn<CategoryFilter>();
  
  var minPrice = RxnDouble();
  var maxPrice = RxnDouble();
  
  // Advanced Filters
  var selectedFacing = "".obs;
  var isCornerPlot = false.obs;
  var selectedMinArea = 0.obs;
  
  // Pagination
  int currentPage = 1;
  bool hasNextPage = true;
  
  // Debounce search
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchSearchResults();
    
    // Add scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!isLoading.value && !isMoreLoading.value && hasNextPage) {
          fetchMoreResults();
        }
      }
    });
  }

  Future<void> fetchSearchResults({bool refresh = true}) async {
    if (refresh) {
      currentPage = 1;
      hasNextPage = true;
      isLoading.value = true;
      searchResults.clear();
    }

    try {
      final response = await _repository.searchProperties(
        page: currentPage,
        search: searchQuery.value,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        categoryId: selectedCategory.value?.id,
        subCategoryId: selectedSubCategory.value?.id,
        subSubCategoryId: selectedSubSubCategory.value?.id,
        facing: selectedFacing.value,
        isCornerPlot: isCornerPlot.value,
        minArea: selectedMinArea.value,
      );

      if (response != null && response.status) {
        if (refresh) {
          searchResults.value = response.data;
        } else {
          searchResults.addAll(response.data);
        }

        if (response.pagination != null) {
          hasNextPage = response.pagination!.currentPage < response.pagination!.lastPage;
          currentPage = response.pagination!.currentPage + 1;
        } else {
          hasNextPage = false;
        }
      }
    } catch (e) {
      print('Search Controller Error: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> fetchMoreResults() async {
    isMoreLoading.value = true;
    await fetchSearchResults(refresh: false);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    
    // Debounce API calls
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSearchResults();
    });
  }

  void applyPriceFilter({double? min, double? max}) {
    minPrice.value = min;
    maxPrice.value = max;
    fetchSearchResults();
  }

  void applyFilters() {
    fetchSearchResults();
  }

  Future<void> fetchCategories() async {
    final result = await _repository.fetchCategories();
    categories.assignAll(result);
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
    fetchSearchResults();
  }

  void onSubCategorySelected(CategoryFilter? subCategory) {
    selectedSubCategory.value = subCategory;
    selectedSubSubCategory.value = null;

    if (subCategory != null) {
      subSubCategories.assignAll(subCategory.children);
    } else {
      subSubCategories.clear();
    }
    fetchSearchResults();
  }

  void onSubSubCategorySelected(CategoryFilter? subSubCategory) {
    selectedSubSubCategory.value = subSubCategory;
    fetchSearchResults();
  }

  void clearFilters() {
    minPrice.value = null;
    maxPrice.value = null;
    selectedCategory.value = null;
    selectedSubCategory.value = null;
    selectedSubSubCategory.value = null;
    selectedFacing.value = "";
    isCornerPlot.value = false;
    selectedMinArea.value = 0;
    subCategories.clear();
    subSubCategories.clear();
    fetchSearchResults();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
