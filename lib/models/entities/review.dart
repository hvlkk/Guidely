import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  const Review({
    required this.grade,
    required this.comment,
    required this.date,
    required this.uid,
    required this.tourId,
  });

  final double grade;
  final String comment;
  final Timestamp date;
  final String uid;
  final String tourId;

  static fromMap(review) {
    return Review(
      grade: review['grade'],
      comment: review['comment'],
      date: review['date'],
      uid: review['userId'],
      tourId: review['tourId'],
    );
  }
}
