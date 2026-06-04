// class RestaurantQueueModel {
//   final int currentServing;
//   final int nextAvailableNumber;

//   RestaurantQueueModel({
//     required this.currentServing,
//     required this.nextAvailableNumber,
//   });

//   factory RestaurantQueueModel.fromMap(Map<String, dynamic> data) {
//     return RestaurantQueueModel(
//         currentServing: data['current_serving'] ?? 0,
//         nextAvailableNumber: data['next_available_number'] ?? 0,
//     );
//   }

//   int get queueLength {
//     final length = nextAvailableNumber - currentServing - 1;
//     return length > 0 ? length : 0;
//   }

//   String get waitStatus {
//     if (queueLength == 0) return 'No Wait';
//     if (queueLength <= 5) return 'Short Wait';
//     if (queueLength <= 10) return 'Long Wait';
//     return 'Busy';
//   }

// }

class RestaurantQueueModel {
  final String brandId;       
  final String restaurantId;  
  final int currentServing;
  final int nextAvailableNumber;

  RestaurantQueueModel({
    required this.brandId,
    required this.restaurantId,
    required this.currentServing,
    required this.nextAvailableNumber,
  });

  factory RestaurantQueueModel.fromMap(Map<String, dynamic> data, String docId) {
    return RestaurantQueueModel(
      // Looks for fields in the map; falls back to using the Firestore document ID for restaurantId if field is omitted
      brandId: data['brand_id'] ?? data['brandId'] ?? '',
      restaurantId: data['restaurant_id'] ?? data['restaurantId'] ?? docId,
      currentServing: data['current_serving'] ?? 0,
      nextAvailableNumber: data['next_available_number'] ?? 0,
    );
  }

  int get queueLength {
    final length = nextAvailableNumber - currentServing - 1;
    return length > 0 ? length : 0;
  }

  String get waitStatus {
    if (queueLength == 0) return 'No Waiting';
    if (queueLength <= 5) return 'Short Wait';
    if (queueLength <= 10) return 'Moderate';
    return 'Busy';
  }
}