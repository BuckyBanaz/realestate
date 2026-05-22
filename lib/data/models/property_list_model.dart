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
    List<dynamic> listData = [];
    Pagination? paginationData;

    if (json['data'] is Map<String, dynamic>) {
      listData = json['data']['data'] ?? [];
      // Use the 'data' object itself as the pagination source if it contains pagination keys
      paginationData = Pagination.fromJson(json['data']);
    } else if (json['data'] is List<dynamic>) {
      listData = json['data'];
    }

    return PropertyListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: listData.map((item) => PropertyListItem.fromJson(item)).toList(),
      pagination: paginationData ?? (json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null),
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
  final int? subSubCategoryId;
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
  final PropertyCategory? subcategory;
  final PropertyCategory? subSubcategory;
  final List<PropertyAttribute> attributes;
  final List<Amenity> amenitiesList;
  final List<PropertyImage> propertyImages;
  final List<PropertyImage> sitePlanImages;
  final List<PropertyImage> threeSixtyView;
  final bool isFavorite;
  final ActiveHold? activeHold;

  PropertyListItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.categoryId,
    this.subcategoryId,
    this.subSubCategoryId,
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
    this.propertyType = '',
    this.status = '',
    this.createdBy = 0,
    this.views,
    this.createdAt = '',
    this.updatedAt = '',
    this.ownerId = 0,
    this.latitude,
    this.longitude,
    this.videoUrl,
    this.amenities,
    this.mainImageUrl,
    this.category,
    this.subcategory,
    this.subSubcategory,
    required this.attributes,
    required this.amenitiesList,
    this.propertyImages = const [],
    this.sitePlanImages = const [],
    this.threeSixtyView = const [],
    this.isFavorite = false,
    this.activeHold,
  });

  factory PropertyListItem.fromJson(Map<String, dynamic> json) {
    // Parse attributes from Map to List<PropertyAttribute>
    List<PropertyAttribute> parsedAttributes = [];
    if (json['attributes'] is Map<String, dynamic>) {
      (json['attributes'] as Map<String, dynamic>).forEach((key, value) {
        parsedAttributes.add(PropertyAttribute(
          id: 0,
          propertyId: json['id'] ?? 0,
          attribute: key,
          value: value?.toString(),
          createdAt: '',
          updatedAt: '',
        ));
      });
    } else if (json['attributes'] is List<dynamic>) {
      parsedAttributes = (json['attributes'] as List<dynamic>)
          .map((attr) => PropertyAttribute.fromJson(attr))
          .toList();
    }

    String? mainImg = json['main_image_url'] ?? json['main_image'];
    if (mainImg != null && !mainImg.startsWith('http')) {
      mainImg = 'http://108.181.185.27/bladmin/public/uploads/properties/$mainImg';
    }

    return PropertyListItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? 0,
      subcategoryId: json['subcategory_id'],
      subSubCategoryId: json['sub_subcategory_id'],
      price: json['price']?.toString() ?? '0',
      area: json['area']?.toString() ?? '',
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      mainImage: mainImg,
      furnishingStatus: json['furnishing_status'],
      propertyType: json['property_type'] ?? '',
      status: json['status'] ?? '',
      createdBy: json['created_by'] ?? 0,
      views: json['views'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      ownerId: json['owner_id'] ?? 0,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      videoUrl: json['video_url'],
      amenities: json['amenities']?.toString(), 
      amenitiesList: _parseAmenities(json['amenities']),
      mainImageUrl: mainImg,
      category: json['category'] != null
          ? PropertyCategory.fromJson(json['category'])
          : null,
      subcategory: json['subcategory'] != null
          ? PropertyCategory.fromJson(json['subcategory'])
          : null,
      subSubcategory: json['sub_subcategory'] != null
          ? PropertyCategory.fromJson(json['sub_subcategory'])
          : null,
      attributes: parsedAttributes,
      propertyImages: _parseImages(json['images'] ?? json['property_images']),
      sitePlanImages: _parseImages(json['map_Properties_images']),
      threeSixtyView: _parseImages(json['three_sixty_view_images']),
      isFavorite: json['is_favourite'] ?? false,
      activeHold: json['active_hold'] != null ? ActiveHold.fromJson(json['active_hold']) : null,
    );
  }

  static List<Amenity> _parseAmenities(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) => Amenity.fromJson(e)).toList();
    }
    if (raw is String && raw.startsWith('[')) {
      try {
        // This handles cases where it's a stringified list of IDs or objects
      } catch (e) {}
    }
    return [];
  }

  static List<PropertyImage> _parseImages(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw.map((item) => PropertyImage.fromJson(item)).toList();
  }
}

class Amenity {
  final int id;
  final String icon;
  final String title;
  final String description;

  Amenity({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] ?? 0,
      icon: json['icon'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
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

class PropertyImage {
  final int id;
  final String image;

  PropertyImage({required this.id, required this.image});

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    String? img = json['image'] ?? json['file_name'];
    if (img != null && !img.startsWith('http')) {
      img = 'http://108.181.185.27/blapis/public/$img';
    }
    return PropertyImage(
      id: json['id'] ?? 0,
      image: img ?? '',
    );
  }
}

class ActiveHold {
  final int id;
  final int propertyId;
  final int userId;
  final String customerName;
  final String customerMobile;
  final String amount;
  final List<String> documents;
  final String holdUntil;
  final String status;
  final String createdAt;
  final String updatedAt;
  final ActiveHoldUser? user;

  ActiveHold({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.customerName,
    required this.customerMobile,
    required this.amount,
    required this.documents,
    required this.holdUntil,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory ActiveHold.fromJson(Map<String, dynamic> json) {
    return ActiveHold(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      customerMobile: json['customer_mobile'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      documents: List<String>.from(json['documents'] ?? []),
      holdUntil: json['hold_until'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] != null ? ActiveHoldUser.fromJson(json['user']) : null,
    );
  }
}

class ActiveHoldUser {
  final int id;
  final String name;
  final String mobileNo;
  final String role;

  ActiveHoldUser({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.role,
  });

  factory ActiveHoldUser.fromJson(Map<String, dynamic> json) {
    return ActiveHoldUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
