import 'package:get/get.dart';
import 'package:realestate/domain/repo/property_repository.dart';
import 'package:realestate/data/models/property_details_model.dart';
import 'package:realestate/data/models/property_list_model.dart';

class PropertyDetailController extends GetxController {
  final PropertyRepository _propertyRepo = PropertyRepository();
  
  var isLoading = true.obs;
  var isPlotsLoading = false.obs;
  var propertyDetails = Rxn<PropertyListItem>();
  var availablePlots = <PropertyListItem>[].obs;
  var selectedPropertyId = 0.obs;

  Future<void> fetchPropertyDetails(int propertyId) async {
    try {
      isLoading.value = true;
      selectedPropertyId.value = propertyId;
      
      final data = await _propertyRepo.fetchPropertyDetails(propertyId);
      if (data != null) {
        propertyDetails.value = data;
        
        // After getting property details, fetch other plots in the same sub-subcategory asynchronously
        fetchRelatedPlots(
          categoryId: data.categoryId,
          subCategoryId: data.subcategoryId,
          subSubCategoryId: data.subSubCategoryId,
        );
      }
    } catch (e) {
      print('PropertyDetailController Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRelatedPlots({
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
  }) async {
    try {
      isPlotsLoading.value = true;
      final response = await _propertyRepo.searchProperties(
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        subSubCategoryId: subSubCategoryId,
        perPage: 50, // Get more plots for selection
      );
      
      if (response != null) {
        availablePlots.assignAll(response.data);
      }
    } catch (e) {
      print('FetchRelatedPlots Error: $e');
    } finally {
      isPlotsLoading.value = false;
    }
  }

  void onPlotSelected(PropertyListItem plot) {
    if (plot.id == selectedPropertyId.value) return;
    fetchPropertyDetails(plot.id);
  }
}
