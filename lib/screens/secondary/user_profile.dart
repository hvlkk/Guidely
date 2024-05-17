import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/review.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/models/enums/tour_guide_auth_state.dart';
import 'package:guidely/widgets/entities/review_list_item.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({
    super.key,
    required this.user,
    this.reviews = const [],
  });

  final User user;
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.imageUrl),
              ),
              const SizedBox(height: 20),
              Text(
                user.username,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (user.authState == TourGuideAuthState.authenticated) ...[
                const Text(
                  'Tour Guide',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Member since 2020',
                  style: TextStyle(fontSize: 16, color: MainColors.textHint),
                ),
                const SizedBox(height: 150),
                if (reviews.isNotEmpty) ...[
                  const Text(
                    'Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ReviewListItem(review: reviews[index]),
                        );
                      },
                    ),
                  ),
                ],
                if (reviews.isEmpty)
                  const Text(
                    'No Reviews yet',
                    style: TextStyle(fontSize: 16, color: MainColors.textHint),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
