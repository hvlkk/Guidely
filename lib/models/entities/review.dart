import 'package:guidely/models/entities/user.dart';

class Review {
  const Review({
    required this.grade,
    required this.comment,
    required this.date,
    required this.user,
  });

  final int grade;
  final String comment;
  final DateTime date;
  final User user;
}