import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/models/entities/tour.dart';

// repsonsible for crud operations on tour data
class TourRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Tour>> getToursStream() {
    return _firestore.collection('tours').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Tour.fromFirestore(doc)).toList(),
        );
  }

  Stream<DocumentSnapshot> getTourStream(String tourId) {
    return _firestore.collection('tours').doc(tourId).snapshots();
  }

  Future<void> updateTourData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('tours').doc(uid).set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTour(String uid) async {
    try {
      await _firestore.collection('tours').doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }
}
