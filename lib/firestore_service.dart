import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static Future<void> updateUserData(
      String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
            data,
            SetOptions(merge: true), // Merge with existing data
          );
    } catch (e) {
      throw Exception("Failed to update user data");
    }
  }

  static Future<void> updateTourData(
      String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('tours').doc(uid).set(
            data,
            SetOptions(merge: true), // Merge with existing data
          );
    } catch (e) {
      throw Exception("Failed to update tour data");
    }
  }
}
