// // models/queue_status_state.dart
// import 'package:flutter/material.dart';

// class QueueStatusState {
//   final Map<String, dynamic> queueData;
//   final Map<String, dynamic> restaurantData;
//   final Map<String, dynamic> brandData;

//   QueueStatusState({
//     required this.queueData,
//     required this.restaurantData,
//     required this.brandData,
//   });

//   // Calculate position separation gaps dynamically
//   int get peopleAhead {
//     int currentServing = queueData['current_serving'] ?? 0;
//     return (currentServing > 0) ? currentServing : 0;
//   }

//   // Pure mathematical ring scaling computations
//   double calculateProgressFactor(int myTicketNumber) {
//     int currentServing = queueData['current_serving'] ?? 0;
//     int gap = myTicketNumber - currentServing;
//     if (gap <= 0) return 1.0;
//     return 1.0 / (gap + 1);
//   }
// }

import 'package:flutter/material.dart';

class QueueStatusState {
  final Map<String, dynamic> queueData;
  final Map<String, dynamic> restaurantData;
  final Map<String, dynamic> brandData;

  QueueStatusState({
    required this.queueData,
    required this.restaurantData,
    required this.brandData,
  });

  // 🎯 FIX: Dynamically pass your ticket number to find your exact wait line placement
  int calculatePeopleAhead(int myTicketNumber) {
    final int currentServing = queueData['current_serving'] ?? 0;
    
    // If the restaurant hasn't started serving anyone yet, everyone with a number lower than you is ahead
    if (currentServing == 0) {
      return myTicketNumber > 0 ? myTicketNumber - 1 : 0;
    }
    
    int gap = myTicketNumber - currentServing;
    return gap < 0 ? 0 : gap;
  }

  // 🎯 FIX: Bulletproof mathematical progress mapping for your circle progress indicator
  double calculateProgressFactor(int myTicketNumber) {
    final int currentServing = queueData['current_serving'] ?? 0;
    
    int gap = myTicketNumber - currentServing;
    
    if (gap <= 0) return 1.0; // You are up! Fill the ring completely.
    
    // Smooth fractional arc scale (e.g., closer you get, the further the ring fills)
    double progress = 1.0 - (gap / myTicketNumber.toDouble());
    return progress.clamp(0.0, 1.0);
  }
}