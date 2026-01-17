import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realestate/domain/repo/auth_repository.dart';
import 'package:realestate/domain/app/local_storage.dart';
import 'package:realestate/screens/widgets/helpers.dart';
import 'package:realestate/data/models/profile_models.dart';
import 'package:realestate/data/models/transaction_model.dart';
import 'package:realestate/data/models/account_data_model.dart';
import 'package:realestate/domain/repo/property_repository.dart';
import 'package:realestate/Routes/appRoutes.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();
  final PropertyRepository _propertyRepo = PropertyRepository();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isLoading = false.obs;
  var isTransactionsLoading = false.obs;
  var isAccountDataLoading = false.obs;
  var selectedImagePath = ''.obs;
  var currentUser = {}.obs;

  // UI state for Profile Screen
  var selectedTab = 0.obs;
  
  // My Properties Data
  final RxList<OwnedProperty> my_property = <OwnedProperty>[].obs;

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  // Payments Data
  final RxList<PaymentItem> upcomingPayments = <PaymentItem>[].obs;
  final RxList<PaymentItem> pastPayments = <PaymentItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchProfileTransactions();
    fetchAccountData();
  }

  Future<void> fetchAccountData() async {
    isAccountDataLoading.value = true;
    try {
      final data = await _propertyRepo.fetchAccountData();
      if (data != null) {
        // Update customer info while preserving other fields (like address or image)
        final Map<String, dynamic> updatedUser = Map<String, dynamic>.from(currentUser);
        updatedUser['id'] = data.customer.id;
        updatedUser['name'] = data.customer.name;
        updatedUser['email'] = data.customer.email;
        updatedUser['phone'] = data.customer.phone;
        
        await LocalStorage().saveUser(updatedUser);
        currentUser.value = updatedUser;

        nameController.text = data.customer.name;
        emailController.text = data.customer.email;
        phoneController.text = data.customer.phone;
        
        // Update properties
        my_property.assignAll(data.properties);

        // Update payments
        final List<PaymentItem> allPayments = [];
        for (var p in data.properties) {
          for (var f in p.finance) {
            allPayments.addAll(f.payments);
          }
        }
        
        upcomingPayments.assignAll(allPayments.where((e) => e.status.toLowerCase() == 'pending').toList());
        pastPayments.assignAll(allPayments.where((e) => e.status.toLowerCase() == 'paid').toList());
      }
    } catch (e) {
      debugPrint("Error fetching account data: $e");
    } finally {
      isAccountDataLoading.value = false;
    }
  }

  Future<void> fetchProfileTransactions() async {
    isTransactionsLoading.value = true;
    try {
      final List<TransactionModel> data = await _propertyRepo.fetchTransactions();
      transactions.assignAll(data);
    } catch (e) {
      debugPrint("Error fetching transactions in profile: $e");
    } finally {
      isTransactionsLoading.value = false;
    }
  }

  void loadUserData() {
    final user = LocalStorage().getUser();
    if (user != null) {
      currentUser.value = user;
      nameController.text = user['name'] ?? '';
      emailController.text = user['email'] ?? '';
      phoneController.text = user['phone'] ?? '';
      addressController.text = user['address'] ?? '';
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      showCustomToast("Error picking image", isError: true);
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || phoneController.text.isEmpty) {
      showCustomToast("Name, email and phone are required", isError: true);
      return;
    }

    isLoading.value = true;
    
    final result = await _authRepo.updateProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      password: passwordController.text.trim(),
      imagePath: selectedImagePath.value.isNotEmpty ? selectedImagePath.value : null,
    );

    isLoading.value = false;

    if (result['success']) {
      final updatedUser = result['data'];
      await LocalStorage().saveUser(updatedUser);
      currentUser.value = updatedUser;
      showCustomToast(result['message'] ?? "Profile updated successfully");
      passwordController.clear();
      selectedImagePath.value = '';
    } else {
      showCustomToast(result['message'] ?? "Profile update failed", isError: true);
    }
  }

  Future<void> logout() async {
    await LocalStorage().clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
