import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/models/entities/review.dart';
import 'package:guidely/providers/user_data_provider.dart';

class ReviewListItem extends ConsumerWidget {
  const ReviewListItem({
    super.key,
    required this.review,
  });

  final Review review;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userSpecificDataProvider(review.uid));

    return user.when(
      data: (user) => Card(
        child: ListTile(
          leading: CircleAvatar(
              backgroundImage: NetworkImage(user.imageUrl),
              ),
          title: Text(user.username),
          subtitle: Text(review.comment),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              review.grade.round(),
              (index) => const Icon(Icons.star, color: Colors.amber),
            ),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Text('Error loading user data'),
    );
  }
}
