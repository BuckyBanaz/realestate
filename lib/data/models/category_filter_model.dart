import 'dart:convert';

class CategoryFilter {
  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final List<String> attributes;
  final String? image;
  final List<CategoryFilter> children;

  CategoryFilter({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    required this.attributes,
    this.image,
    required this.children,
  });

  factory CategoryFilter.fromJson(Map<String, dynamic> json) {
    List<String> parsedAttributes = [];
    if (json['attributes'] != null) {
      if (json['attributes'] is List) {
        parsedAttributes = (json['attributes'] as List).map((e) => e.toString()).toList();
      } else if (json['attributes'] is String && (json['attributes'] as String).isNotEmpty) {
        try {
          final decoded = jsonDecode(json['attributes']);
          if (decoded is List) {
            parsedAttributes = decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          // Fallback if it's not a JSON list
        }
      }
    }

    return CategoryFilter(
      id: json['id'] ?? 0,
      parentId: json['parent_id'],
      name: json['name'] ?? "",
      slug: json['slug'] ?? "",
      attributes: parsedAttributes,
      image: json['image'],
      children: (json['children'] as List?)
              ?.map((e) => CategoryFilter.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CategoryFilterResponse {
  final bool status;
  final String message;
  final List<CategoryFilter> data;

  CategoryFilterResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryFilterResponse.fromJson(Map<String, dynamic> json) {
    return CategoryFilterResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      data: (json['data'] as List?)
              ?.map((e) => CategoryFilter.fromJson(e))
              .toList() ??
          [],
    );
  }
}
