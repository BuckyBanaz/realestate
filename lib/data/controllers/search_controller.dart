import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realestate/data/models/property_list_model.dart';
import 'package:realestate/domain/repo/property_repository.dart';

class PropertySearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final PropertyRepository _repository = PropertyRepository();
  
  var searchQuery = "".obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var searchResults = <PropertyListItem>[].obs;
  var selectedCategory = "All".obs;
  
  // Pagination
  int currentPage = 1;
  bool hasNextPage = true;
  
  // Debounce search
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
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

  void selectCategory(String category) {
    selectedCategory.value = category;
    fetchSearchResults();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
