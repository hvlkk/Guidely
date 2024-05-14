import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guidely/services/firestore_service.dart';

class UserService extends FirestoreService {
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

  static Future<void> updateData(
      BuildContext context, String uid, Map<String, dynamic> data) async {
    final service = UserService();
    await service.update('users', uid, data);
  }
}
