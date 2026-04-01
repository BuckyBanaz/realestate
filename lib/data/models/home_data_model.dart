class HomeDataModel {
  final bool status;
  final String message;
  final List<CategoryWithProperties> categories;
  final List<TopLocation> topLocations;
  final List<NewsItem> news;

  HomeDataModel({
    required this.status,
    required this.message,
    required this.categories,
    required this.topLocations,
    required this.news,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      categories: (json['categories_with_properties'] as List?)
              ?.map((e) => CategoryWithProperties.fromJson(e))
              .toList() ??
          [],
      topLocations: (json['top_location'] as List?)
              ?.map((e) => TopLocation.fromJson(e))
              .toList() ??
          [],
      news: (json['news'] as List?)
              ?.map((e) => NewsItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CategoryWithProperties {
  final int id;
  final String name;
  final String? imageUrl;
  final List<PropertyModel> properties;
  final int totalProperties;

  CategoryWithProperties({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.properties,
    required this.totalProperties,
  });

  factory CategoryWithProperties.fromJson(Map<String, dynamic> json) {
    return CategoryWithProperties(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      imageUrl: json['image_url'],
      properties: (json['properties'] as List?)
              ?.map((e) => PropertyModel.fromJson(e))
              .toList() ??
          [],
      totalProperties: json['total_properties'] ?? 0,
    );
  }
}

class PropertyModel {
  final int id;
  final String title;
  final String price;
  final String area;
  final String address;
  final String? propertyImage;
  final bool isFavourite;

  PropertyModel({
    required this.id,
    required this.title,
    required this.price,
    required this.area,
    required this.address,
    this.propertyImage,
    required this.isFavourite,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      price: json['price'] ?? "0",
      area: json['area'] ?? "",
      address: json['address'] ?? "",
      propertyImage: json['property_image'],
      isFavourite: json['is_favourite'] ?? false,
    );
  }
}

class TopLocation {
  final int id;
  final String title;
  final String address;
  final String? propertyImage;

  TopLocation({
    required this.id,
    required this.title,
    required this.address,
    this.propertyImage,
  });

  factory TopLocation.fromJson(Map<String, dynamic> json) {
    return TopLocation(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      address: json['address'] ?? "",
      propertyImage: json['property_image'],
    );
  }
}

class NewsItem {
  final int id;
  final String title;
  final String description;
  final String type;
  final String? videoUrl;
  final String? resourceImage;
  final String createdAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.videoUrl,
    this.resourceImage,
    required this.createdAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      type: json['type'] ?? "",
      videoUrl: json['video_url'],
      resourceImage: json['resource_image'],
      createdAt: json['created_at'] ?? "",
    );
  }
}
