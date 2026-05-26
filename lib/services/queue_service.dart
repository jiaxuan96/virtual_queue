import 'package:cloud_firestore/cloud_firestore.dart';

class QueueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Function to join a restaurant's queue
  Future<int?> joinQueue(String restaurantId, String userId) async {
    // Reference to the restaurant's queue document
    DocumentReference queueRef = _db.collection('queues').doc(restaurantId);

    // Using a Firestore Transaction to prevent two users from getting the same number
    return _db.runTransaction((transaction) async {
      DocumentSnapshot queueSnapshot = await transaction.get(queueRef);

      if (!queueSnapshot.exists) {
        // If the queue doesn't exist yet, initialize it
        transaction.set(queueRef, {
          'current_serving': 1,
          'next_available_number': 2,
        });
        
        // Create the first ticket
        _createNewTicket(queueRef, 1, userId);
        return 1;
      }

      // If it exists, read the next available number
      Map<String, dynamic> data = queueSnapshot.data() as Map<String, dynamic>;
      int assignedNumber = data['next_available_number'];

      // Increment the next available number in the database
      transaction.update(queueRef, {
        'next_available_number': assignedNumber + 1,
      });

      // Create the user's ticket inside the sub-collection
      _createNewTicket(queueRef, assignedNumber, userId);

      return assignedNumber; // Return the assigned number to show on the UI
    });
  }

  // Helper method to create a ticket document
  void _createNewTicket(DocumentReference queueRef, int number, String userId) {
    queueRef.collection('tickets').add({
      'queue_number': number,
      'status': 'WAITING',
      'user_id': userId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}