// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:virtual_queue/models/restaurant_queue_model.dart';

// class QueueService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // Function to join a restaurant's queue
//   Future<int?> joinQueue(String restaurantId, String userId) async {
//     // Reference to the restaurant's queue document
//     DocumentReference queueRef = _db.collection('queues').doc(restaurantId);

//     // Using a Firestore Transaction to prevent two users from getting the same number
//     return _db.runTransaction((transaction) async {
//       DocumentSnapshot queueSnapshot = await transaction.get(queueRef);

//       if (!queueSnapshot.exists) {
//         // If the queue doesn't exist yet, initialize it
//         transaction.set(queueRef, {
//           'current_serving': 1,
//           'next_available_number': 2,
//         });
        
//         // Create the first ticket
//         _createNewTicket(queueRef, 1, userId);
//         return 1;
//       }

//       // If it exists, read the next available number
//       Map<String, dynamic> data = queueSnapshot.data() as Map<String, dynamic>;
//       int assignedNumber = data['next_available_number'];

//       // Increment the next available number in the database
//       transaction.update(queueRef, {
//         'next_available_number': assignedNumber + 1,
//       });

//       // Create the user's ticket inside the sub-collection
//       _createNewTicket(queueRef, assignedNumber, userId);

//       return assignedNumber; // Return the assigned number to show on the UI
//     });
//   }

//   // Helper method to create a ticket document
//   void _createNewTicket(DocumentReference queueRef, int number, String userId) {
//     queueRef.collection('tickets').add({
//       'queue_number': number,
//       'status': 'WAITING',
//       'user_id': userId,
//       'created_at': FieldValue.serverTimestamp(),
//     });
//   }

//   // --- Restaurant Side --- //
//   // Listens to live queue changes from Firestore
//   Stream<RestaurantQueueModel> watchRestaurantQueue(String restaurantId) {
//     return _db.collection('queues').doc(restaurantId).snapshots().map((doc){
//       final data = doc.data() as Map<String, dynamic>? ?? {};
//       // Convert data to model
//       return RestaurantQueueModel.fromMap(data);
//     });
//   }

//   // Update current serving when staff pressing Call Next
//   Future<void> callNextCustomer(String restaurantId) async {
//     await _db.collection('queues').doc(restaurantId).update({
//       'current_serving': FieldValue.increment(1),
//     });
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtual_queue/models/restaurant_queue_model.dart';
import 'package:flutter/material.dart';

class QueueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Function to join a restaurant's queue 
  // Future<int?> joinQueue({
  //   required String brandId, 
  //   required String restaurantId, 
  //   required String userId,
  // }) async {
  //   // Reference to the restaurant's queue document
  //   DocumentReference queueRef = _db.collection('queues').doc(restaurantId);
    
  //   // USER PROFILE SHORTCUT REFERENCE: Path: users -> userId -> active_queue -> restaurantId
  //   DocumentReference userShortcutRef = _db
  //       .collection('users')
  //       .doc(userId)
  //       .collection('active_queue')
  //       .doc(restaurantId);

  //   return _db.runTransaction((transaction) async {
  //     DocumentSnapshot queueSnapshot = await transaction.get(queueRef);

  //     int assignedNumber;

  //     if (!queueSnapshot.exists) {
  //       assignedNumber = 1;
        
  //       transaction.set(queueRef, {
  //         'brand_id': brandId,
  //         'restaurant_id': restaurantId,
  //         'current_serving': 1,
  //         'next_available_number': 2,
  //       });
  //     } else {
  //       Map<String, dynamic> data = queueSnapshot.data() as Map<String, dynamic>;
  //       assignedNumber = data['next_available_number'] ?? 1;

  //       transaction.update(queueRef, {
  //         'next_available_number': assignedNumber + 1,
  //         'brand_id': data['brand_id'] ?? brandId,
  //         'restaurant_id': data['restaurant_id'] ?? restaurantId,
  //       });
  //     }

  //     // 1. Generate a document reference inside the subcollection first
  //     DocumentReference ticketRef = queueRef.collection('tickets').doc();
  //     final String generatedTicketId = ticketRef.id; // 🚀 FIX: Extract the ID string explicitly!

  //     // 2. Write to master tickets subcollection inside the transaction block
  //     transaction.set(ticketRef, {
  //       'queue_number': assignedNumber,
  //       'status': 'WAITING',
  //       'user_id': userId,
  //       'created_at': FieldValue.serverTimestamp(),
  //     });

  //     // 3. Write directly to the user profile collection inside the same transaction loop
  //     transaction.set(userShortcutRef, {
  //       'ticket_id': generatedTicketId, // 🚀 FIX: Map it here so fetchActiveUserTicket() doesn't return null!
  //       'brand_id': brandId,
  //       'restaurant_id': restaurantId,
  //       'ticket_number': assignedNumber,
  //       'status': 'WAITING',
  //       'joined_at': FieldValue.serverTimestamp(),
  //     });

  //     return assignedNumber; 
  //   });
  // }

  // Function to join a restaurant's queue 
  Future<int?> joinQueue({
    required String brandId, 
    required String restaurantId, 
    required String userId,
  }) async {
    // 🚀 1. PRE-CHECK VALIDATION: Check if this user already has an active 'WAITING' ticket anywhere
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
          'current_serving': 1,
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

  // Update current serving when staff pressing Call Next
  Future<void> callNextCustomer(String restaurantId) async {
    final DocumentReference queueRef = _db.collection('queues').doc(restaurantId);
    final CollectionReference ticketsRef = queueRef.collection('tickets');

    await _db.runTransaction((transaction) async {
      final DocumentSnapshot queueSnapshot = await transaction.get(queueRef);
      if (!queueSnapshot.exists) return;

      final Map<String, dynamic> queueData = queueSnapshot.data() as Map<String, dynamic>;
      final int currentServing = queueData['current_serving'] ?? 1;

      // 1. Find the ticket matching this current serving number
      final QuerySnapshot ticketMatch = await ticketsRef
          .where('queue_number', isEqualTo: currentServing)
          .where('status', isEqualTo: 'WAITING')
          .limit(1)
          .get();

      if (ticketMatch.docs.isNotEmpty) {
        final DocumentSnapshot ticketDoc = ticketMatch.docs.first;
        final Map<String, dynamic> ticketData = ticketDoc.data() as Map<String, dynamic>;
        final String? userId = ticketData['user_id'];

        // Update master archive log
        transaction.update(ticketDoc.reference, {'status': 'SERVED'});

        // 2. 🚀 UPDATE USER PROFILE SUBCOLLECTION (Instead of deleting)
        if (userId != null && userId.isNotEmpty) {
          final DocumentReference userShortcutRef = _db
              .collection('users')
              .doc(userId)
              .collection('active_queue')
              .doc(restaurantId);

          // Mark it as SERVED in their personal document history tree
          transaction.update(userShortcutRef, {'status': 'SERVED'});
        }
      }

      // 3. Increment the master branch serving tracker counter
      transaction.update(queueRef, {
        'current_serving': currentServing + 1,
      });
    });
  }
}