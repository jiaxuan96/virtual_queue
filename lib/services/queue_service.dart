import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_queue/models/restaurant_queue_model.dart';
import 'package:flutter/material.dart';

class QueueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Function to join a restaurant's queue 
  Future<int?> joinQueue({
    required String brandId, 
    required String restaurantId, 
    required String userId,
  }) async {
    // 1. PRE-CHECK VALIDATION: Check if this user already has an active 'WAITING' ticket anywhere
    final QuerySnapshot existingActiveQueues = await _db
        .collection('users')
        .doc(userId)
        .collection('active_queue')
        .where('status', isEqualTo: 'WAITING')
        .limit(1)
        .get();

    // If an active ticket is found, abort the process immediately!
    if (existingActiveQueues.docs.isNotEmpty) {
      debugPrint('🚫 [QueueService] Join blocked: User $userId is already waiting in an active line.');
      throw Exception('You cannot join a new queue while you are already holding an active ticket.');
    }

    // -------------------------------------------------------------------------
    // 2. Continuing with original execution loop if validation clear:
    // -------------------------------------------------------------------------
    
    // Reference to the restaurant's queue document
    DocumentReference queueRef = _db.collection('queues').doc(restaurantId);
    
    // USER PROFILE SHORTCUT REFERENCE: Path: users -> userId -> active_queue -> restaurantId
    DocumentReference userShortcutRef = _db
        .collection('users')
        .doc(userId)
        .collection('active_queue')
        .doc(restaurantId);

    return _db.runTransaction((transaction) async {
      DocumentSnapshot queueSnapshot = await transaction.get(queueRef);

      int assignedNumber;

      if (!queueSnapshot.exists) {
        assignedNumber = 1;
        
        transaction.set(queueRef, {
          'brand_id': brandId,
          'restaurant_id': restaurantId,
          'current_serving': 0,
          'next_available_number': 2,
        });
      } else {
        Map<String, dynamic> data = queueSnapshot.data() as Map<String, dynamic>;
        assignedNumber = data['next_available_number'] ?? 1;

        transaction.update(queueRef, {
          'next_available_number': assignedNumber + 1,
          'brand_id': data['brand_id'] ?? brandId,
          'restaurant_id': data['restaurant_id'] ?? restaurantId,
        });
      }

      // Generate a document reference inside the subcollection first
      DocumentReference ticketRef = queueRef.collection('tickets').doc();
      final String generatedTicketId = ticketRef.id; 

      // Write to master tickets subcollection inside the transaction block
      transaction.set(ticketRef, {
        'queue_number': assignedNumber,
        'status': 'WAITING',
        'user_id': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Write directly to the user profile collection inside the same transaction loop
      transaction.set(userShortcutRef, {
        'ticket_id': generatedTicketId, 
        'brand_id': brandId,
        'restaurant_id': restaurantId,
        'ticket_number': assignedNumber,
        'status': 'WAITING',
        'joined_at': FieldValue.serverTimestamp(),
      });

      return assignedNumber; 
    });
  }

  // --- Restaurant Side --- //
  // Listens to live queue changes from Firestore
  Stream<RestaurantQueueModel> watchRestaurantQueue(String restaurantId) {
    return _db.collection('queues').doc(restaurantId).snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return RestaurantQueueModel.fromMap(data, doc.id);
    });
  }

  // WAITING = customer joined, not called yet
  // CALLED = now serving
  // SERVED = finished
  // CANCELLED = skipped

  // Update current serving when staff pressing Call Next
  Future<void> callNextCustomer(String restaurantId) async {
    final queueRef = _db.collection('queues').doc(restaurantId);
    final ticketsRef = queueRef.collection('tickets');

    await _db.runTransaction((transaction) async {
      final queueSnapshot = await transaction.get(queueRef);
      if (!queueSnapshot.exists) return;

      final queueData = queueSnapshot.data() as Map<String, dynamic>;
      final currentServing = queueData['current_serving'] ?? 0;

      // 1. If there is already a called customer,
      //    finish that customer first before calling the next one.
      if (currentServing > 0) {
        final currentTicketMatch = await ticketsRef
            .where('queue_number', isEqualTo: currentServing)
            .where('status', isEqualTo: 'CALLED')
            .limit(1)
            .get();

        if (currentTicketMatch.docs.isNotEmpty) {
          final ticketDoc = currentTicketMatch.docs.first;
          final ticketData = ticketDoc.data() as Map<String, dynamic>;
          final userId = ticketData['user_id'];

          // Move current customer from CALLED to SERVED.
          transaction.update(ticketDoc.reference, {'status': 'SERVED'});

          // 2. 🚀 UPDATE USER PROFILE SUBCOLLECTION (Instead of deleting)
          if (userId != null && userId.isNotEmpty) {
            final userShortcutRef = _db
                .collection('users')
                .doc(userId)
                .collection('active_queue')
                .doc(restaurantId);

            // Mark it as SERVED in their personal document history tree
            transaction.update(userShortcutRef, {'status': 'SERVED'});
          }
        }
      }

      // Find the next waiting customer after the current serving number.
      final nextTicketMatch = await ticketsRef
          .where('status', isEqualTo: 'WAITING')
          .where('queue_number', isGreaterThan: currentServing)
          .orderBy('queue_number')
          .limit(1)
          .get();

      // If no waiting customer, set current_serving to 0.
      if (nextTicketMatch.docs.isEmpty) {
        transaction.update(queueRef, {
          'current_serving': 0,
        });
        return;
      }

      final nextTicketData = nextTicketMatch.docs.first.data() as Map<String, dynamic>;

      final nextQueueNumber = nextTicketData['queue_number'] ?? 0;

      final nextUserId = nextTicketData['user_id'];

      // Move next customer from WAITING to CALLED.
      transaction.update(nextTicketMatch.docs.first.reference, {
        'status': 'CALLED',
        'called_at': FieldValue.serverTimestamp(),
      });

      // UPDATE USER PROFILE SUBCOLLECTION
      if (nextUserId != null && nextUserId.toString().isNotEmpty) {
        final userShortcutRef = _db
            .collection('users')
            .doc(nextUserId)
            .collection('active_queue')
            .doc(restaurantId);

        transaction.update(userShortcutRef, {
          'status': 'CALLED',
          'called_at': FieldValue.serverTimestamp(),
        });
      }

      transaction.update(queueRef, {
        'current_serving': nextQueueNumber,
      });
    });
  }

  // Skip the no-show customer when staff pressing skip
  Future<void> skipCurrentCustomer(String restaurantId) async {
    final queueRef = _db.collection('queues').doc(restaurantId);
    final ticketsRef = queueRef.collection('tickets');

    await _db.runTransaction((transaction) async {
      final queueSnapshot = await transaction.get(queueRef);

      if (!queueSnapshot.exists) return;

      // Convert Firestore document data into Map.
      final queueData = queueSnapshot.data() as Map<String, dynamic>;
      final currentServing = queueData['current_serving'] ?? 0;

      if (currentServing <= 0) return;

      // Find the ticket that has the same number as currentServing.
      final ticketMatch = await ticketsRef
          .where('queue_number', isEqualTo: currentServing)
          .where('status', isEqualTo: 'CALLED')
          .limit(1)
          .get();

      // If the ticket exists, update its status to CANCELLED.
      if (ticketMatch.docs.isNotEmpty) {
        final ticketDoc = ticketMatch.docs.first;
        final ticketData = ticketDoc.data() as Map<String, dynamic>;
        final userId = ticketData['user_id'];

        transaction.update(ticketDoc.reference, {
          'status': 'CANCELLED',
          'cancelled_at': FieldValue.serverTimestamp(),
        });

        if (userId != null && userId.toString().isNotEmpty) {
          final userShortcutRef = _db
              .collection('users')
              .doc(userId)
              .collection('active_queue')
              .doc(restaurantId);

          transaction.update(userShortcutRef, {
            'status': 'CANCELLED',
            'cancelled_at': FieldValue.serverTimestamp(),
          });
        }
      }

      transaction.update(queueRef, {
        'current_serving': 0,
      });
    });
  }

  Stream<int> watchWaitingTicketCount(String restaurantId) {
    return _db
        .collection('queues')
        .doc(restaurantId)
        .collection('tickets')
        .where('status', isEqualTo: 'WAITING')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}