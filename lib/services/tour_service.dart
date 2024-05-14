import 'package:guidely/repositories/tour_repository.dart';
import 'package:guidely/services/firestore_service.dart';
import 'package:flutter/material.dart';

class TourService extends FirestoreService {
  @override
  Future<void> update(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    await TourRepository().updateTourData(docId, data);
  }

  // interface for updating tour data
  static Future<void> updateTourData(
      BuildContext context, String uid, Map<String, dynamic> data) async {
    final service = TourService();
    await service.update('tours', uid, data);
  }
}
