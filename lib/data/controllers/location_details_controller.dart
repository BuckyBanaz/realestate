import 'package:get/get.dart';
import 'package:realestate/domain/repo/location_repository.dart';
import 'package:realestate/data/models/location_details_model.dart';

class LocationDetailsController extends GetxController {
  final LocationRepository _locationRepo = LocationRepository();
  
  var isLoading = true.obs;
  var locationData = Rxn<LocationDetailsModel>();
  var properties = <LocationProperty>[].obs;

  Future<void> fetchLocationDetails(int addressId) async {
    isLoading.value = true;
    final data = await _locationRepo.fetchLocationProperties(addressId);
    if (data != null) {
      locationData.value = data;
      properties.value = data.data;
    }
    isLoading.value = false;
  }
}
