import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_endpoints.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

// ─── Category Model ───────────────────────────────────────────────────────────
class CategoryNode {
  final int id;
  final String name;
  final List<CategoryNode> children;

  const CategoryNode({
    required this.id,
    required this.name,
    required this.children,
  });

  factory CategoryNode.fromJson(Map<String, dynamic> json) {
    final kids = json['children'];
    return CategoryNode(
      id:       json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name:     json['name']?.toString() ?? '',
      children: kids is List
          ? kids.map((c) => CategoryNode.fromJson(c as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryNode>>(
        CategoriesNotifier.new);

class CategoriesNotifier extends AsyncNotifier<List<CategoryNode>> {
  @override
  Future<List<CategoryNode>> build() async {
    // Ensure auth token is set before calling
    await ref.read(authProvider.future);

    try {
      final res = await ref.read(apiClientProvider).get(ApiEndpoints.categories);
      final raw = res.data;
      final list = raw['data'] is List ? raw['data'] as List : [];
      return list
          .map((e) => CategoryNode.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      dev.log('[CategoriesNotifier] build() failed: $e', name: 'CategoriesProvider', error: e, stackTrace: stack);
      return [];
    }
  }
}
