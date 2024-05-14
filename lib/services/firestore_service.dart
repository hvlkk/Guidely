import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Private constructor for singleton
  FirestoreService._privateConstructor();

  static final FirestoreService instance =
      FirestoreService._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateData(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) {
    return _updateData('users', uid, data);
  }

  Future<void> updateTourData(String uid, Map<String, dynamic> data) {
    return _updateData('tours', uid, data);
  }
}
