class Review {
  const Review({
    required this.grade,
    required this.comment,
    required this.date,
    required this.uid,
    required this.tourId,
  });

  final int grade;
  final String comment;
  final DateTime date;
  final String uid;
  final String tourId;
}
