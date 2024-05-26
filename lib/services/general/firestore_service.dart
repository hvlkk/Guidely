import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> update(
      String collectionPath, String docId, Map<String, dynamic> data);
}
