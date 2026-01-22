class ResourcesResponse {
  final bool status;
  final String message;
  final List<ResourceItem> data;

  ResourcesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ResourcesResponse.fromJson(Map<String, dynamic> json) {
    return ResourcesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List?)
              ?.map((e) => ResourceItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ResourceItem {
  final int id;
  final String title;
  final String description;
  final String? resourceImage;
  final String type;
  final String? videoUrl;
  final String createdAt;

  ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    this.resourceImage,
    required this.type,
    this.videoUrl,
    required this.createdAt,
  });

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      resourceImage: json['resource_image'],
      type: json['type'] ?? 'maps',
      videoUrl: json['video_url'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
