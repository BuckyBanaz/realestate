class LocationDetailsModel {
  final bool status;
  final String message;
  final String address;
  final String mainImage;
  final List<LocationProperty> data;

  LocationDetailsModel({
    required this.status,
    required this.message,
    required this.address,
    required this.mainImage,
    required this.data,
  });

  factory LocationDetailsModel.fromJson(Map<String, dynamic> json) {
    return LocationDetailsModel(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      address: json['address'] ?? "",
      mainImage: json['main_image'] ?? "",
      data: (json['data'] as List?)
              ?.map((e) => LocationProperty.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class LocationProperty {
  final int id;
  final String title;
  final String address;
  final String price;
  final String area;
  final String propertyImage;
  final bool propertyFavourites;

  LocationProperty({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.area,
    required this.propertyImage,
    required this.propertyFavourites,
  });

  factory LocationProperty.fromJson(Map<String, dynamic> json) {
    return LocationProperty(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      address: json['address'] ?? "",
      price: json['price'] ?? "0",
      area: json['area'] ?? "",
      propertyImage: json['property_image'] ?? "",
      propertyFavourites: json['property_favourites'] ?? false,
    );
  }
}
