class FavoriteProperty {
  final int id;
  final String title;
  final String address;
  final String price;
  final String area;
  final String image;

  FavoriteProperty({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.area,
    required this.image,
  });

  factory FavoriteProperty.fromJson(Map<String, dynamic> json) {
    return FavoriteProperty(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      price: json['price']?.toString() ?? '0',
      area: json['area']?.toString() ?? '',
      image: json['image'] ?? '',
    );
  }
}

class FavoritesResponse {
  final bool status;
  final int total;
  final List<FavoriteProperty> data;

  FavoritesResponse({
    required this.status,
    required this.total,
    required this.data,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      status: json['status'] ?? false,
      total: json['total'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => FavoriteProperty.fromJson(e))
              .toList() ??
          [],
    );
  }
}
