import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import '../models/restaurant_brand_model.dart';
import '../models/restaurant_queue_model.dart'; // Imported your model!

class RestaurantDisplayState {
  final RestaurantModel restaurant;
  final RestaurantBrandModel brand;
  final RestaurantQueueModel queue; // Holds your updated model instance
  final int queueLength;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;

  RestaurantDisplayState({
    required this.restaurant,
    required this.brand,
    required this.queue,
    required this.queueLength,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
  });
}

class CustomerHomeViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RestaurantDisplayState>> get restaurantCardsStream {
    return _firestore.collection('queues').snapshots().asyncMap((queueSnapshot) async {
      List<RestaurantDisplayState> displayCards = [];

      for (var queueDoc in queueSnapshot.docs) {
        try {
          final queueData = queueDoc.data();
          
          // 1. Instantiate your queue model directly
          final queueModel = RestaurantQueueModel.fromMap(queueData, queueDoc.id);

          // 2. Extract structural look-ups 
          final String brandId = queueModel.brandId;
          final String restaurantId = queueModel.restaurantId;

          if (brandId.isEmpty || restaurantId.isEmpty) {
            debugPrint('⚠️ Skipped Queue Doc [${queueDoc.id}]: Missing brand_id reference links inside document mapping entries.');
            continue;
          }

          // 3. Fetch Parent Brand Profile Document 
          final brandDoc = await _firestore
              .collection('restaurant_brands')
              .doc(brandId)
              .get();

          // 4. Fetch Child Branch Document inside the subcollection
          final restaurantDoc = await _firestore
              .collection('restaurant_brands')
              .doc(brandId)
              .collection('restaurants')
              .doc(restaurantId)
              .get();

          if (brandDoc.exists && restaurantDoc.exists) {
            final brandModel = RestaurantBrandModel.fromMap(brandDoc.data()!);
            final restaurantModel = RestaurantModel.fromMap(restaurantDoc.data()!);

            // 5. Build presentation state utilizing your built-in model calculations
            final cardState = _calculateCardPresentation(restaurantModel, brandModel, queueModel);
            displayCards.add(cardState);
          } else {
            debugPrint('❌ Missing subcollection files on server side for Brand: $brandId, Branch: $restaurantId');
          }
        } catch (error) {
          debugPrint('🚨 Core loop error hydrater execution line fail: $error');
        }
      }

      return displayCards;
    });
  }

  RestaurantDisplayState _calculateCardPresentation(
    RestaurantModel restaurant,
    RestaurantBrandModel brand,
    RestaurantQueueModel queue,
  ) {
    // Utilize your exact native queue calculations!
    final int currentQueueLength = queue.queueLength;
    final String statusString = queue.waitStatus;

    // Set colors based on your native model wait statuses
    Color badgeBgColor = const Color(0xFF008645); 
    Color badgeTextColor = const Color(0xFFFFFFFF);

    // if (statusString == 'Short wait') {
    //   badgeBgColor = const Color(0xFFF39850); 
    // } else if (statusString == 'Moderate') {
    //   badgeBgColor = const Color(0xFFFF7890);
    // } else if (statusString == 'Busy') {
    //   badgeBgColor = const Color(0xFFBA1A1A); 
    // }

    if (statusString == 'No waiting') {
      badgeBgColor = const Color(0xFF008645); // Deep Green
    } else if (statusString == 'Short wait') {
      badgeBgColor = const Color(0xFFF39850); // Warning Amber
    } else if (statusString == 'Moderate') {
      badgeBgColor = const Color(0xFFFF7890); // Soft Coral/Pink
    } else if (statusString == 'Busy') {
      badgeBgColor = const Color(0xFFBA1A1A); // Alert Crimson Red
    }

    return RestaurantDisplayState(
      restaurant: restaurant,
      brand: brand,
      queue: queue,
      queueLength: currentQueueLength,
      badgeText: statusString,
      badgeBgColor: badgeBgColor,
      badgeTextColor: badgeTextColor,
    );
  }
}