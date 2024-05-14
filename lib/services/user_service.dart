import 'package:flutter/material.dart';
import 'package:guidely/repositories/user_repository.dart';
import 'package:guidely/services/firestore_service.dart';

class UserService extends FirestoreService {
  @override
  Future<void> update(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    await UserRepository().updateUserData(docId, data);
  }

  // interface for updating user data
  static Future<void> updateData(
      BuildContext context, String uid, Map<String, dynamic> data) async {
    final service = UserService();
    await service.update('users', uid, data);
  }
}
