// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:guidely/blocs/util/review_bloc.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/widgets/customs/custom_text_field.dart';

class ReviewCreatorScreen extends StatefulWidget {
  const ReviewCreatorScreen(
      {super.key, required this.tour, required this.userData});

  final Tour tour;
  final User userData;

  @override
  State<ReviewCreatorScreen> createState() => _ReviewCreatorScreenState();
}

class _ReviewCreatorScreenState extends State<ReviewCreatorScreen> {
  late final _reviewBloc;
  double rating = 0;

  @override
  void initState() {
    super.initState();
    _reviewBloc = ReviewBloc(userData: widget.userData);
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
          children: [
            const SizedBox(height: 25),
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
                this.rating = rating;
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if(_reviewBloc.submitReview(rating, widget.tour)) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review submitted'),
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a review'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
