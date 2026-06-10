import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart'; 
import '../models/restaurant_display_state.dart';
import '../models/restaurant_model.dart';
import '../models/restaurant_brand_model.dart';
import '../models/restaurant_queue_model.dart';

// (Keep your RestaurantDisplayState class here exactly as it is)

class CustomerHomeViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🎯 FIX: BehaviorSubject buffers the last emitted value. 
  // Even if the UI listens late, it will immediately receive the active filter!
  final BehaviorSubject<String?> _filterSubject = BehaviorSubject<String?>.seeded(null);

  // 🎯 The view UI calls this method to change selection states
  void applyCuisineFilter(String? cuisine) {
    debugPrint('⚡ [ViewModel] UI requested category change to: "$cuisine"');
    _filterSubject.add(cuisine); 
  }

  /// 🎧 DRIVER STREAM: Reacts to BOTH filter clicks AND real-time database updates!
  Stream<List<RestaurantDisplayState>> get restaurantCardsStream {
    // CombineLatest2 combines our local filter events with live backend database streams
    return Rx.combineLatest2<String?, QuerySnapshot, Stream<List<RestaurantDisplayState>>>(
      _filterSubject.stream,
      _firestore.collection('restaurant_brands').snapshots(), // 🕒 Real-time Firestore stream listener
      (activeFilter, brandSnapshot) {
        
        // This inner block runs asynchronously to stitch our subcollections together
        return Stream.fromFuture(_fetchDisplayStates(activeFilter, brandSnapshot));
      },
    ).flatMap((aminoStream) => aminoStream); // Flattens our nested stream structures out smoothly
  }

  /// Helper method that handles the heavy lifting of fetching subcollections & mapping states
  // 📁 viewmodels/customer_home_viewmodel.dart

  Future<List<RestaurantDisplayState>> _fetchDisplayStates(String? activeCuisineFilter, QuerySnapshot brandSnapshot) async {
    List<RestaurantDisplayState> displayCards = [];

    for (var brandDoc in brandSnapshot.docs) {
      try {
        final brandData = brandDoc.data() as Map<String, dynamic>;
        final brandModel = RestaurantBrandModel.fromMap(brandData);
        final String brandId = brandDoc.id;

        // 🎯 1. BRAND-LEVEL FILTER CHECK:
        // Since 'cuisine' is inside the Brand document, check it before opening branches!
        if (activeCuisineFilter != null) {
          final String dbCuisine = (brandData['cuisine'] ?? '').toString().trim().toLowerCase();
          final String selectedCuisine = activeCuisineFilter.trim().toLowerCase();
          
          // If this master brand doesn't match the clicked category, skip all its branches entirely!
          if (dbCuisine != selectedCuisine) {
            continue; 
          }
        }

        // 🟢 2. FETCH BRANCHES: Only read branches for brands matching our category
        Query restaurantCollectionRef = _firestore
            .collection('restaurant_brands')
            .doc(brandId)
            .collection('restaurants');

        final restaurantQuery = await restaurantCollectionRef.get();

        for (var restaurantDoc in restaurantQuery.docs) {
          final String restaurantId = restaurantDoc.id;
          final restaurantModel = RestaurantModel.fromMap(restaurantDoc.data() as Map<String, dynamic>);

          // 🟢 3. FETCH LIVE QUEUES
          final queueDoc = await _firestore
              .collection('queues')
              .doc(restaurantId)
              .get();

          RestaurantQueueModel queueModel;
          if (queueDoc.exists) {
            queueModel = RestaurantQueueModel.fromMap(queueDoc.data()!, queueDoc.id);
          } else {
            queueModel = RestaurantQueueModel.fromMap({
              'brand_id': brandId,
              'restaurant_id': restaurantId,
              'current_serving': 0,
              'next_available_number': 1,
            }, restaurantId);
          }

          final cardState = _calculateCardPresentation(restaurantModel, brandModel, queueModel);
          displayCards.add(cardState);
        }
      } catch (e) {
        debugPrint('🚨 Subcollection filtering alignment exception: $e');
      }
    }
    return displayCards;
  }

  RestaurantDisplayState _calculateCardPresentation(
    RestaurantModel restaurant,
    RestaurantBrandModel brand,
    RestaurantQueueModel queue,
  ) {
    final int currentQueueLength = queue.queueLength;
    final String statusString = currentQueueLength == 0 ? 'No waiting' : queue.waitStatus;

    Color badgeBgColor = const Color(0xFF008645); 
    if (statusString == 'Short wait') badgeBgColor = const Color(0xFFF39850); 
    if (statusString == 'Moderate') badgeBgColor = const Color(0xFFFF7890); 
    if (statusString == 'Busy') badgeBgColor = const Color(0xFFBA1A1A); 

    return RestaurantDisplayState(
      restaurant: restaurant,
      brand: brand,
      queue: queue,
      queueLength: currentQueueLength,
      badgeText: statusString,
      badgeBgColor: badgeBgColor,
      badgeTextColor: Colors.white,
    );
  }

  // Close resources to cleanly avoid system memory leaks
  void dispose() {
    _filterSubject.close();
  }
}