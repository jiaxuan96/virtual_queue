class RestaurantBrandModel {
  final String name;
  final String cuisine;
  final String about;

  RestaurantBrandModel({
    required this.name,
    required this.cuisine,
    required this.about,
  });

  factory RestaurantBrandModel.fromMap(Map<String, dynamic> data) {
    return RestaurantBrandModel(
        name: data['name'] ?? '',
        cuisine: data['cuisine'] ?? '',
        about: data['about'] ?? '',
    );
  }
}