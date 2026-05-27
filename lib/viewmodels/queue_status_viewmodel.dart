// viewmodels/queue_status_viewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/queue_status_state.dart';

class QueueStatusViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QueueStatusState> getLiveTrackingStream({
    required String brandId,
    required String restaurantId,
  }) {
    // 1. Establish the reactive core real-time tracker
    final queueSnapshotStream = _firestore.collection('queues').doc(restaurantId).snapshots();

    return queueSnapshotStream.asyncMap((queueSnap) async {
      // 2. Hydrate configuration parameters by reading master files
      final brandSnap = await _firestore.collection('restaurant_brands').doc(brandId).get();
      
      // 3. Drill down into the child subcollection path
      final restSnap = await _firestore
          .collection('restaurant_brands')
          .doc(brandId)
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      return QueueStatusState(
        queueData: queueSnap.data() as Map<String, dynamic>? ?? {},
        restaurantData: restSnap.data() as Map<String, dynamic>? ?? {},
        brandData: brandSnap.data() as Map<String, dynamic>? ?? {},
      );
    });
  }
}