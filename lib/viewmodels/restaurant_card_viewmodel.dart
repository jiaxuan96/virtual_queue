// viewmodels/restaurant_card_viewmodel.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Required for debugPrint
import '../services/queue_service.dart';
import '../models/restaurant_detail_state.dart';

class RestaurantCardViewModel {
  final QueueService _queueService = QueueService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return firebaseUser.uid; // ✅ Returns actual Firestore uid matching your AuthService setup
    }
    
    // Fail-safe protective tracking fallback for local debugging profiles
    debugPrint('⚠️ [VM Session Alert] No authenticated session detected. Using secure temporary context.');
    return "anonymous_guest_or_test_id"; 
  }

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

      // 🔍 Debug logs to verify structural sync is succeeding
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

  Future<void> saveToBookmarks({required String userId, required String restaurantId, required String brandId}) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(restaurantId) // Store using restaurantId as document ID to make checks incredibly easy
          .set({
            'restaurant_id': restaurantId,
            'brand_id': brandId,
            'saved_at': FieldValue.serverTimestamp(),
          });
      debugPrint('💾 [Firestore] Bookmark saved successfully.');
    } catch (e) {
      debugPrint('🚨 [Firestore Error] Failed to save bookmark: $e');
    }
  }

  // 🗑️ Remove bookmark from user profile subcollection
  Future<void> removeFromBookmarks({required String userId, required String restaurantId}) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(restaurantId)
          .delete();
      debugPrint('💾 [Firestore] Bookmark removed successfully.');
    } catch (e) {
      debugPrint('🚨 [Firestore Error] Failed to delete bookmark: $e');
    }
  }

  Future<int?> joinQueueLine({
    required String brandId,
    required String restaurantId,
    String? userId,
  }) async {
    final String targetUserId = userId ?? currentUserId;

    debugPrint('🎫 [VM Queue Request] Forwarding request to QueueService for User: $targetUserId');

    return await _queueService.joinQueue(
      brandId: brandId,
      restaurantId: restaurantId,
      userId: targetUserId,
    );
  }
}