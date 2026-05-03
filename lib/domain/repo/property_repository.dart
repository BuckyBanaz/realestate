import 'package:dio/dio.dart';
import 'package:realestate/domain/api/api_client.dart';
import 'package:realestate/data/models/property_details_model.dart';

import 'package:realestate/data/models/transaction_model.dart';
import 'package:realestate/data/models/owner_document_model.dart';
import 'package:realestate/data/models/account_data_model.dart';
import 'package:realestate/data/models/property_list_model.dart';
import 'package:realestate/data/models/favorite_model.dart';
import 'package:realestate/data/models/category_filter_model.dart';

class PropertyRepository {
  final ApiClient _apiClient = ApiClient();

  Future<PropertyListItem?> fetchPropertyDetails(int propertyId) async {
    try {
      final response = await _apiClient.dio.get('property/$propertyId');
      if (response.statusCode == 200 && response.data['status'] == true) {
        return PropertyListItem.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        print("PropertyRepo Error: ${e.message}");
        if (e.response != null) {
          print("PropertyRepo Error Response: ${e.response?.data}");
        }
      }
      return null;
    }
  }

  Future<List<TransactionModel>> fetchTransactions() async {
    try {
      final response = await _apiClient.dio.get('transactions');
      if (response.statusCode == 200) {
        final res = TransactionResponse.fromJson(response.data);
        return res.data;
      }
      return [];
    } catch (e) {
      print("Transaction Error: $e");
      return [];
    }
  }

  Future<List<OwnerDocumentGroup>> fetchOwnerDocuments() async {
    try {
      final response = await _apiClient.dio.get('owner-documents');
      if (response.statusCode == 200) {
        final res = OwnerDocumentResponse.fromJson(response.data);
        return res.data;
      }
      return [];
    } catch (e) {
      print("Owner Documents Error: $e");
      return [];
    }
  }

  Future<AccountData?> fetchAccountData() async {
    try {
      final response = await _apiClient.dio.get('account-data');
      if (response.statusCode == 200) {
        final res = AccountDataResponse.fromJson(response.data);
        return res.data;
      }
      return null;
    } catch (e) {
      print("Account Data Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> saveEnquiry({
    required int propertyId,
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'Inquiry-save',
        data: {
          'property_id': propertyId,
          'name': name,
          'email': email,
          'phone': phone,
          'message': message,
        },
      );
         if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['status'] == true) {
        return {
          'success': true,
          'message':
              response.data['message'] ?? 'Inquiry submitted successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to submit enquiry',
        };
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null && e.response!.data != null) {
          return {
            'success': false,
            'message': e.response!.data['message'] ?? 'An error occurred',
          };
        }
      }
      return {'success': false, 'message': 'Failed to connect to server'};
    }
  }

  Future<List<PropertyListItem>> fetchAllProperties() async {
    try {
      final response = await _apiClient.dio.get('properties');
      if (response.statusCode == 200) {
        final res = PropertyListResponse.fromJson(response.data);
        return res.data;
      }
      return [];
    } catch (e) {
      print('Fetch All Properties Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> toggleFavorite(int propertyId) async {
    try {
      final response = await _apiClient.dio.post(
        'property/favourite-toggle',
        data: {'property_id': propertyId},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Success',
          'is_favourite': response.data['is_favourite'] ?? false,
        };
      }
      return {
        'success': false,
        'message': 'Failed to toggle favorite',
        'is_favourite': false,
      };
    } catch (e) {
      print('Toggle Favorite Error: $e');

      // Check for 401 Unauthorized
      if (e is DioException && e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'is_favourite': false,
          'unauthorized': true,
        };
      }

      return {
        'success': false,
        'message': 'An error occurred',
        'is_favourite': false,
      };
    }
  }

  Future<FavoritesResponse?> fetchFavorites() async {
    try {
      final response = await _apiClient.dio.get('favourites-list');

      if (response.statusCode == 200) {
        return FavoritesResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Fetch Favorites Error: $e');
      return null;
    }
  }

  Future<PropertyListResponse?> searchProperties({
    int page = 1,
    int perPage = 10,
    double? minPrice,
    double? maxPrice,
    String? search,
    int? categoryId,
    int? subCategoryId,
    int? subSubCategoryId,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'per_page': perPage,
      };

      if (minPrice != null) queryParameters['min_price'] = minPrice;
      if (maxPrice != null) queryParameters['max_price'] = maxPrice;
      if (search != null && search.isNotEmpty)
        queryParameters['search'] = search;
      if (categoryId != null) queryParameters['category_id'] = categoryId;
      if (subCategoryId != null) queryParameters['subcategory_id'] = subCategoryId;
      if (subSubCategoryId != null) queryParameters['sub_subcategory_id'] = subSubCategoryId;

      final response = await _apiClient.dio.get(
        'properties',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return PropertyListResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Search Properties Error: $e');
      return null;
    }
  }

  Future<List<CategoryFilter>> fetchCategories() async {
    try {
      final response = await _apiClient.dio.get('categories');
      if (response.statusCode == 200) {
        final res = CategoryFilterResponse.fromJson(response.data);
        return res.data;
      }
      return [];
    } catch (e) {
      print("Fetch Categories Error: $e");
      return [];
    }
  }
}
