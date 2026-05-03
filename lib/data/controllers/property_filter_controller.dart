import 'package:get/get.dart';
import 'package:realestate/data/models/category_filter_model.dart';
import 'package:realestate/domain/repo/property_repository.dart';

class PropertyFilterController extends GetxController {
  final PropertyRepository _propertyRepo = PropertyRepository();

  var categories = <CategoryFilter>[].obs;
  var subCategories = <CategoryFilter>[].obs;
  var subSubCategories = <CategoryFilter>[].obs;

  var selectedCategory = Rxn<CategoryFilter>();
  var selectedSubCategory = Rxn<CategoryFilter>();
  var selectedSubSubCategory = Rxn<CategoryFilter>();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    final result = await _propertyRepo.fetchCategories();
    categories.assignAll(result);
    isLoading.value = false;
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
  }

  void onSubCategorySelected(CategoryFilter? subCategory) {
    selectedSubCategory.value = subCategory;
    selectedSubSubCategory.value = null;

    if (subCategory != null) {
      subSubCategories.assignAll(subCategory.children);
    } else {
      subSubCategories.clear();
    }
  }

  void onSubSubCategorySelected(CategoryFilter? subSubCategory) {
    selectedSubSubCategory.value = subSubCategory;
  }

  void resetFilters() {
    selectedCategory.value = null;
    selectedSubCategory.value = null;
    selectedSubSubCategory.value = null;
    subCategories.clear();
    subSubCategories.clear();
  }
}
