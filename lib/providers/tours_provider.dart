import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/models/entities/tour.dart';

// A provider that returns a stream of all tours
final toursStreamProvider = StreamProvider.autoDispose<List<Tour>>((ref) {
  return FirebaseFirestore.instance.collection('tours').snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Tour.fromMap(doc.data())).toList());
});
