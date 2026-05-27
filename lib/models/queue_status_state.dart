// models/queue_status_state.dart
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

  // Calculate position separation gaps dynamically
  int get peopleAhead {
    int currentServing = queueData['current_serving'] ?? 0;
    return (currentServing > 0) ? currentServing : 0;
  }

  // Pure mathematical ring scaling computations
  double calculateProgressFactor(int myTicketNumber) {
    int currentServing = queueData['current_serving'] ?? 0;
    int gap = myTicketNumber - currentServing;
    if (gap <= 0) return 1.0;
    return 1.0 / (gap + 1);
  }
}