class QuizItem {
  final String correctAnswer = "";
  late String question;
  late List<String?> options;
  String photoURL = "";
  bool isTrueOrFalse = false;

  QuizItem({
    required this.question,
    required this.options,
    this.photoURL = "",
    this.isTrueOrFalse = false,
  });
}
