import 'package:get/get.dart';
import 'package:realestate/data/models/owner_document_model.dart';
import 'package:realestate/domain/repo/property_repository.dart';

class DocumentController extends GetxController {
  final PropertyRepository _repo = PropertyRepository();
  
  var isLoading = true.obs;
  var documentGroups = <OwnerDocumentGroup>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    isLoading.value = true;
    final List<OwnerDocumentGroup> data = await _repo.fetchOwnerDocuments();
    documentGroups.assignAll(data);
    isLoading.value = false;
  }

  Future<void> onRefresh() async {
    await fetchDocuments();
  }
}
