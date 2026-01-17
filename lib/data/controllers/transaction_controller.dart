import 'package:get/get.dart';
import 'package:realestate/data/models/transaction_model.dart';
import 'package:realestate/domain/repo/property_repository.dart';

class TransactionController extends GetxController {
  final PropertyRepository _repo = PropertyRepository();
  
  var isLoading = true.obs;
  var transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    final List<TransactionModel> data = await _repo.fetchTransactions();
    transactions.assignAll(data);
    isLoading.value = false;
  }

  Future<void> onRefresh() async {
    await fetchTransactions();
  }
}
