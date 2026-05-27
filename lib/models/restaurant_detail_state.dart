import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantDetailState {
  final Map<String, dynamic> brandData;
  final Map<String, dynamic> restaurantData;
  final Map<String, dynamic> queueData;

  RestaurantDetailState({
    required this.brandData,
    required this.restaurantData,
    required this.queueData,
  });

  // Business Logic: Computing Badge UI Attributes dynamically
  int get queueLength {
    int peopleAhead = (queueData['next_available_number'] ?? 1) - (queueData['current_serving'] ?? 0) - 1;
    return peopleAhead > 0 ? peopleAhead : 0;
  }

  String get badgeText {
    if (queueLength == 0) return 'No waiting';
    if (queueLength <= 5) return 'Short wait';
    if (queueLength <= 10) return 'Moderate';
    return 'Busy';
  }

  Color get badgeBgColor {
    if (queueLength == 0) return const Color(0xFF008645);
    if (queueLength <= 5) return const Color(0xFFF39850);
    if (queueLength <= 10) return const Color(0xFFFF7890);
    return const Color(0xFFBA1A1A);
  }
}