import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/models/entities/review.dart';
import 'package:guidely/services/tour_service.dart';

class ReviewService {
  static Future<void> addReview(String tourId, Review review) async {
    final Map<String, dynamic> reviewData = {
      'tourId': review.tourId,
      'userId': review.uid,
      'comment': review.comment,
      'grade': review.grade,
      'date': review.date.toIso8601String(),
    };
    await TourService.updateTourData(tourId, {
      // here arrayUnion is used to add the review to the reviews array
      'reviews': FieldValue.arrayUnion([reviewData]),
    });
  }
}
