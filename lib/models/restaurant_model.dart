class RestaurantModel {
  final String branchName;
  final String brandId;
  final String address;
  final String openingHours;
  final String phone;
  final int estimatedTime;
  final bool isActive;

  RestaurantModel({
    required this.branchName,
    required this.brandId,
    required this.address,
    required this.openingHours,
    required this.phone,
    required this.estimatedTime,
    required this.isActive,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> data) {
    return RestaurantModel(
      branchName: data['branch_name'] ?? '',
      brandId: data['brand_id'] ?? '',
      address: data['address'] ?? '',
      openingHours: data['opening_hours'] ?? '',
      phone: data['phone'] ?? '',
      estimatedTime: data['estimated_time'] ?? 0,
      isActive: data['is_active'] ?? false,
    );
  }
}
