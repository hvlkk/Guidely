import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/repositories/tour_repository.dart';
import 'package:guidely/services/general/firestore_service.dart';

class TourService extends FirestoreService {
  @override
  Future<void> update(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    await TourRepository().updateTourData(docId, data);
  }

  // interface for updating tour data
  static Future<void> updateTourData(
      String uid, Map<String, dynamic> data) async {
    final service = TourService();
    await service.update('tours', uid, data);
  }

  // Interface for streaming tour data by ID
  static Stream<DocumentSnapshot> getTourStream(String tourId) {
    return TourRepository().getTourStream(tourId);
  }

  // interface for deleting tour data
  static Future<void> deleteTour(String uid) async {
    await TourRepository().deleteTour(uid);
  }
}
