import 'package:flutter/material.dart';
import 'package:guidely/models/entities/review.dart';

class ReviewListItem extends StatelessWidget {
  const ReviewListItem({
    super.key,
    required this.review,
  });

  final Review review;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            // backgroundImage: AssetImage(review.user.imageUrl),
            ),
        title: Text(review.uid),
        subtitle: Text(review.comment),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            review.grade.round(),
            (index) => const Icon(Icons.star, color: Colors.amber),
          ),
        ),
      ),
    );
  }
}
