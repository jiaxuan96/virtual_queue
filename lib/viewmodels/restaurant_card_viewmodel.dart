// viewmodels/restaurant_card_viewmodel.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Required for debugPrint
import '../services/queue_service.dart';
import '../models/restaurant_detail_state.dart';

class RestaurantCardViewModel {
  final QueueService _queueService = QueueService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<RestaurantDetailState> getRestaurantDetailStream({
    required String brandId,
    required String restaurantId,
  }) {
    // 1. Listen to real-time changes on the root 'queues' document
    final queueStream = _firestore.collection('queues').doc(restaurantId).snapshots();

    return queueStream.asyncMap((queueSnap) async {
      debugPrint('📥 [VM Query] Requesting Documents ➔ Brand ID: "$brandId" | Restaurant ID: "$restaurantId"');

      // 2. Fetch the parent brand document from root collection
      final brandSnap = await _firestore.collection('restaurant_brands').doc(brandId).get();
      
      // 3. ✅ FIXED: Walk down the subcollection path to fetch the specific restaurant branch
      final restSnap = await _firestore
          .collection('restaurant_brands')
          .doc(brandId)
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      final brandMap = brandSnap.data() as Map<String, dynamic>? ?? {};
      final restMap = restSnap.data() as Map<String, dynamic>? ?? {};
      final queueMap = queueSnap.data() as Map<String, dynamic>? ?? {};

      // 🔍 Debug logs to verify your structural sync is succeeding
      debugPrint('📦 [VM Payload Result] Brands Doc Exists: ${brandSnap.exists} -> Keys: ${brandMap.keys.toList()}');
      debugPrint('📦 [VM Payload Result] Restaurants Subdoc Exists: ${restSnap.exists} -> Keys: ${restMap.keys.toList()}');
      debugPrint('📦 [VM Payload Result] Full Restaurant Map Content: $restMap');

      return RestaurantDetailState(
        brandData: brandMap,
        restaurantData: restMap,
        queueData: queueMap,
      );
    });
  }

  Future<int?> joinQueueLine({
    required String brandId,
    required String restaurantId,
    required String userId,
  }) async {
    return await _queueService.joinQueue(
      brandId: brandId,
      restaurantId: restaurantId,
      userId: userId,
    );
  }
}