import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guidely/models/entities/review.dart';
import 'package:guidely/services/review_service.dart';

abstract class ReviewState {}

class ReviewSubmitted extends ReviewState {}

class ReviewError extends ReviewState {
  ReviewError(this.message);

  final String message;
}

class ReviewBloc {
  final _reviewController = StreamController<ReviewState>.broadcast();
  Stream<ReviewState> get reviewState => _reviewController.stream;

  final TextEditingController _textContoller = TextEditingController();

  TextEditingController get textContoller => _textContoller;

  void submitReview(int rating, String tourid) {
    String comment = _textContoller.text;
    if (comment.isEmpty) {
      submitError('Please enter a review');
      return;
    }

    Review review = Review(
      comment: comment,
      grade: rating,
      date: DateTime.now(),
      uid: 'user.uid',
      tourId: tourid,
    );

    // save review to database
    ReviewService.addReview(tourid, review);
  }

  void submitError(String message) {
    _reviewController.add(ReviewError(message));
  }

  void dispose() {
    _reviewController.close();
  }
}
