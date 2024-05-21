import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guidely/models/entities/review.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/services/review_service.dart';

abstract class ReviewState {}

class ReviewSubmitted extends ReviewState {}

class ReviewError extends ReviewState {
  ReviewError(this.message);

  final String message;
}

class ReviewBloc {
  ReviewBloc({required this.userData});

  final User userData;

  final _reviewController = StreamController<ReviewState>.broadcast();
  Stream<ReviewState> get reviewState => _reviewController.stream;

  final TextEditingController _textContoller = TextEditingController();

  TextEditingController get textContoller => _textContoller;

  bool submitReview(double rating, Tour tour) {
    String comment = _textContoller.text;
    if (comment.isEmpty) {
      submitError('Please enter a review');
      return false;
    }

    Review review = Review(
      comment: comment,
      grade: rating,
      date: Timestamp.now(),
      uid: userData.uid,
      tourId: tour.uid,
    );
    tour.reviews.add(review);
    ReviewService.addReview(tour.uid, review);
    return true;
  }

  void submitError(String message) {
    _reviewController.add(ReviewError(message));
  }

  void dispose() {
    _reviewController.close();
  }
}
