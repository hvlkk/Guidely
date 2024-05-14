import 'package:guidely/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TourService extends FirestoreService {
  @override
  Future<void> update(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await firestore.collection(collectionPath).doc(docId).set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateTourData(
      BuildContext context, String uid, Map<String, dynamic> data) async {
    final service = TourService();
    await service.update('tours', uid, data);
  }
}
