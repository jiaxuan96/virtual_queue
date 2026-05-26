import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_queue/models/restaurant_model.dart';
import 'package:virtual_queue/models/restaurant_brand_model.dart';

class RestaurantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<RestaurantBrandModel> watchRestaurant(String restaurantBrandId) {
    return _db
        .collection('restaurant_brands')
        .doc(restaurantBrandId)
        .snapshots()
        .map((doc){
      final data = doc.data() ?? {};
      return RestaurantBrandModel.fromMap(data);
    });
  }

  Stream<RestaurantModel> watchRestaurantBranch(String restaurantBrandId, String restaurantId) {
    return _db
        .collection('restaurant_brands')
        .doc(restaurantBrandId)
        .collection('restaurants')
        .doc(restaurantId)
        .snapshots()
        .map((doc){
      final data = doc.data() ?? {};
      return RestaurantModel.fromMap(data);
    });
  }

}
// restaurant_brands/{brandId}/restaurants/{restaurantId}