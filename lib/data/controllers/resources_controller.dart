import 'package:get/get.dart';
import 'package:realestate/data/models/resources_model.dart';
import 'package:realestate/domain/repo/resources_repository.dart';

class ResourcesController extends GetxController {
  final ResourcesRepository _repository = ResourcesRepository();

  final RxList<ResourceItem> resources = <ResourceItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchResources();
  }

  Future<void> fetchResources() async {
    isLoading.value = true;
    try {
      final response = await _repository.fetchResources();
      if (response != null && response.status) {
        resources.value = response.data;
      } else {
        resources.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }
}
