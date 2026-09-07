import 'dart:io';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_endpoints.dart';
import 'auth_provider.dart';
import 'api_provider.dart';

final documentsProvider = AsyncNotifierProvider<DocumentsNotifier, List<Map<String, dynamic>>>(
  DocumentsNotifier.new,
);

class DocumentsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final token = await ref.watch(authProvider.future);
    if (token == null) return [];

    try {
      final res = await ref.read(apiClientProvider).get(ApiEndpoints.documents);
      final data = res.data;
      
      if (data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e, stack) {
      dev.log('[DocumentsNotifier] build() failed: $e', name: 'DocumentsProvider', error: e, stackTrace: stack);
      rethrow; // surface error so DocumentsScreen shows its error+retry branch
    }
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<bool> uploadDocument({
    required String filePath,
    required String documentType,
  }) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;

      final fileName = file.path.split(RegExp(r'[/\\]')).last;

      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        'document_type': documentType,
      });

      final res = await ref.read(apiClientProvider).postFormData(
        ApiEndpoints.documents,
        data: formData,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e, stack) {
      dev.log('[DocumentsNotifier] uploadDocument() failed: $e', name: 'DocumentsProvider', error: e, stackTrace: stack);
      return false;
    }
  }
}
