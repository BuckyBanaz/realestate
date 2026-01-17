import 'package:get/get.dart';
import 'package:realestate/domain/repo/property_repository.dart';
import 'package:realestate/data/models/property_details_model.dart';

class PropertyDetailController extends GetxController {
  final PropertyRepository _propertyRepo = PropertyRepository();
  
  var isLoading = true.obs;
  var propertyDetails = Rxn<PropertyDetailsModel>();

  Future<void> fetchPropertyDetails(int propertyId) async {
    isLoading.value = true;
    final data = await _propertyRepo.fetchPropertyDetails(propertyId);
    if (data != null) {
      propertyDetails.value = data;
    }
    isLoading.value = false;
  }
}
