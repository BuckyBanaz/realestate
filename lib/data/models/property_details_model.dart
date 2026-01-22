import 'dart:convert';

class PropertyDetailsModel {
  final bool status;
  final String viewType;
  final PropertyDetailData property;
  final List<SimilarProperty> similar;
  final List<PlotData> plotData;
  final List<Amenity> amenities;

  PropertyDetailsModel({
    required this.status,
    required this.viewType,
    required this.property,
    required this.similar,
    required this.plotData,
    required this.amenities,
  });

  factory PropertyDetailsModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailsModel(
      status: json['status'] ?? false,
      viewType: json['viewType'] ?? "",
      property: PropertyDetailData.fromJson(json['property'] ?? {}),
      similar: (json['similar'] as List?)
              ?.map((e) => SimilarProperty.fromJson(e))
              .toList() ??
          [],
      plotData: (json['plotData'] as List?)
              ?.map((e) => PlotData.fromJson(e))
              .toList() ??
          [],
      amenities: (json['amenities'] as List?)
              ?.map((e) => Amenity.fromJson(e))
              .toList() ??
          [],
    );
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

class PlotData {
  final int id;
  final String number;
  final String size;
  final String status;

  PlotData({
    required this.id,
    required this.number,
    required this.size,
    required this.status,
  });

  factory PlotData.fromJson(Map<String, dynamic> json) {
    return PlotData(
      id: json['id'] ?? 0,
      number: json['number'] ?? "",
      size: json['size'] ?? "",
      status: json['status'] ?? "active",
    );
  }
}

class PropertyThreeSixtyView {
  final String image;
  PropertyThreeSixtyView({required this.image});
  factory PropertyThreeSixtyView.fromJson(Map<String, dynamic> json) {
    return PropertyThreeSixtyView(image: json['image'] ?? "");
  }
}

class SitePlanImage {
  final String image;
  SitePlanImage({required this.image});
  factory SitePlanImage.fromJson(Map<String, dynamic> json) {
    return SitePlanImage(image: json['image'] ?? "");
  }
}

class PropertyDetailData {
  final int id;
  final String title;
  final String slug;
  final String address;
  final String price;
  final String area;
  final String status;
  final int views;
  final String? category;
  final String? subCategory;
  final List<PropertyAttribute> attributes;
  final List<String> amenities;
  final String mainImage;
  final List<String> propertyImages;
  final List<PropertyThreeSixtyView> threeSixtyView;
  final List<SitePlanImage> sitePlanImages;
  final bool isFavorite;
  final String? videoUrl;

  PropertyDetailData({
    required this.id,
    required this.title,
    required this.slug,
    required this.address,
    required this.price,
    required this.area,
    required this.status,
    required this.views,
    this.category,
    this.subCategory,
    required this.attributes,
    required this.amenities,
    required this.mainImage,
    required this.propertyImages,
    required this.threeSixtyView,
    required this.sitePlanImages,
    this.isFavorite = false,
    this.videoUrl,
  });

  factory PropertyDetailData.fromJson(Map<String, dynamic> json) {
    try {
      // Parse amenities from string "[\"1\",\"2\"]" or list
      List<String> parsedAmenities = [];
      final rawAmenities = json['amenities'];
      if (rawAmenities != null) {
        if (rawAmenities is String && rawAmenities.isNotEmpty) {
          try {
            final decoded = jsonDecode(rawAmenities);
            if (decoded is List) {
              parsedAmenities = decoded.map((e) => e.toString()).toList();
            }
          } catch (e) {
            print("Error parsing amenities: $e");
          }
        } else if (rawAmenities is List) {
          parsedAmenities = rawAmenities.map((e) => e.toString()).toList();
        }
      }

      final propertyData = PropertyDetailData(
        id: json['id'] ?? 0,
        title: json['title'] ?? "",
        slug: json['slug'] ?? "",
        address: json['address'] ?? "",
        price: json['price']?.toString() ?? "0",
        area: json['area']?.toString() ?? "",
        status: json['status']?.toString() ?? "",
        views: json['views'] ?? 0,
        category: json['category']?.toString(),
        subCategory: json['subcategory']?.toString(),
        attributes: (json['attributes'] as List?)
                ?.map((e) => PropertyAttribute.fromJson(e))
                .toList() ??
            [],
        amenities: parsedAmenities,
        mainImage: json['main_image'] ?? "",
        propertyImages: (json['property_images'] as List?)?.map((e) => e.toString()).toList() ?? [],
        threeSixtyView: (json['360_view'] as List?)
                ?.map((e) => PropertyThreeSixtyView.fromJson(e))
                .toList() ??
            [],
        sitePlanImages: (json['map_Properties_images'] as List?)
                ?.map((e) => SitePlanImage.fromJson(e))
                .toList() ??
            [],
        videoUrl: json['video_url']?.toString(),
        isFavorite: json['isFavourite'] ?? json['is_favourite'] ?? json['is_favorite'] ?? false,
      );
      
      // Debug: Check if is_favorite is coming from API
      print("Property ID: ${json['id']}, Title: ${json['title']}, is_favorite from API: ${json['is_favorite']}");
      
      return propertyData;
    } catch (e, stack) {
      print("Error parsing PropertyDetailData: $e");
      print(stack);
      rethrow;
    }
  }
}

class PropertyCategory {
  final int id;
  final String name;
  final String subCategory;
  final String image;

  PropertyCategory({
    required this.id,
    required this.name,
    required this.subCategory,
    required this.image,
  });

  factory PropertyCategory.fromJson(Map<String, dynamic> json) {
    return PropertyCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      subCategory: json['subCategory'] ?? "",
      image: json['image'] ?? "",
    );
  }
}

class PropertyAttribute {
  final int id;
  final String attribute;
  final String? value;

  PropertyAttribute({
    required this.id,
    required this.attribute,
    this.value,
  });

  factory PropertyAttribute.fromJson(Map<String, dynamic> json) {
    return PropertyAttribute(
      id: json['id'] ?? 0,
      attribute: json['attribute'] ?? "",
      value: json['value'],
    );
  }
}

class SimilarProperty {
  final int id;
  final String title;
  final String address;
  final String image;

  SimilarProperty({
    required this.id,
    required this.title,
    required this.address,
    required this.image,
  });

  factory SimilarProperty.fromJson(Map<String, dynamic> json) {
    return SimilarProperty(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      address: json['address'] ?? "",
      image: json['image'] ?? "",
    );
  }
}
