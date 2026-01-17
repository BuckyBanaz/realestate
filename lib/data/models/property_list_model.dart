class PropertyListResponse {
  final bool status;
  final String message;
  final List<PropertyListItem> data;
  final Pagination? pagination;

  PropertyListResponse({
    required this.status,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
    return PropertyListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => PropertyListItem.fromJson(item))
              .toList() ??
          [],
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : null,
    );
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class PropertyListItem {
  final int id;
  final String title;
  final String slug;
  final String description;
  final int categoryId;
  final int? subcategoryId;
  final String price;
  final String area;
  final int? bedrooms;
  final int? bathrooms;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String? mainImage;
  final String? furnishingStatus;
  final String propertyType;
  final String status;
  final int createdBy;
  final int? views;
  final String createdAt;
  final String updatedAt;
  final int ownerId;
  final String? latitude;
  final String? longitude;
  final String? videoUrl;
  final String? amenities;
  final String? mainImageUrl;
  final PropertyCategory? category;
  final List<PropertyAttribute> attributes;

  PropertyListItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.categoryId,
    this.subcategoryId,
    required this.price,
    required this.area,
    this.bedrooms,
    this.bathrooms,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    this.mainImage,
    this.furnishingStatus,
    required this.propertyType,
    required this.status,
    required this.createdBy,
    this.views,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerId,
    this.latitude,
    this.longitude,
    this.videoUrl,
    this.amenities,
    this.mainImageUrl,
    this.category,
    required this.attributes,
  });

  factory PropertyListItem.fromJson(Map<String, dynamic> json) {
    return PropertyListItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? 0,
      subcategoryId: json['subcategory_id'],
      price: json['price']?.toString() ?? '0',
      area: json['area']?.toString() ?? '',
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      mainImage: json['main_image'],
      furnishingStatus: json['furnishing_status'],
      propertyType: json['property_type'] ?? '',
      status: json['status'] ?? '',
      createdBy: json['created_by'] ?? 0,
      views: json['views'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      ownerId: json['owner_id'] ?? 0,
      latitude: json['latitude'],
      longitude: json['longitude'],
      videoUrl: json['video_url'],
      amenities: json['amenities'],
      mainImageUrl: json['main_image_url'],
      category: json['category'] != null
          ? PropertyCategory.fromJson(json['category'])
          : null,
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((attr) => PropertyAttribute.fromJson(attr))
              .toList() ??
          [],
    );
  }
}

class PropertyCategory {
  final int id;
  final String name;
  final String subCategory;
  final String slug;
  final String? attributes;
  final String? image;
  final String createdAt;
  final String updatedAt;

  PropertyCategory({
    required this.id,
    required this.name,
    required this.subCategory,
    required this.slug,
    this.attributes,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyCategory.fromJson(Map<String, dynamic> json) {
    return PropertyCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      subCategory: json['subCategory'] ?? '',
      slug: json['slug'] ?? '',
      attributes: json['attributes'],
      image: json['image'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class PropertyAttribute {
  final int id;
  final int propertyId;
  final String attribute;
  final String? value;
  final String createdAt;
  final String updatedAt;

  PropertyAttribute({
    required this.id,
    required this.propertyId,
    required this.attribute,
    this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyAttribute.fromJson(Map<String, dynamic> json) {
    return PropertyAttribute(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      attribute: json['attribute'] ?? '',
      value: json['value'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
