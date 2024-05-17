// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:guidely/blocs/util/review_bloc.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/widgets/customs/custom_text_field.dart';

class ReviewCreatorScreen extends StatefulWidget {
  const ReviewCreatorScreen({super.key, required this.tour});

  final Tour tour;

  @override
  State<ReviewCreatorScreen> createState() => _ReviewCreatorScreenState();
}

class _ReviewCreatorScreenState extends State<ReviewCreatorScreen> {
  late final _reviewBloc;
  late final String rating;

  @override
  void initState() {
    super.initState();
    _reviewBloc = ReviewBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create a review for ${widget.tour.tourDetails.title}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            CustomTextField(controller: _reviewBloc.textContoller),
            const SizedBox(height: 10),
            RatingBar.builder(
              initialRating: 0,
              minRating: 0.5,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                this.rating = rating.toString();
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _reviewBloc.submitReview(rating, widget.tour.uid);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
