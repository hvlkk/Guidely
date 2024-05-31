class QuizItem {
  final int correctAnswer;
  late String question;
  late List<String> options;
  String photoURL = "";
  bool isTrueOrFalse = false;

  QuizItem({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.photoURL = "",
    this.isTrueOrFalse = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'photoURL': photoURL,
      'isTrueOrFalse': isTrueOrFalse,
    };
  }

  factory QuizItem.fromMap(Map<String, dynamic> map) {
    return QuizItem(
      question: map['question'],
      options: List<String>.from(map['options']),
      correctAnswer: map['correctAnswer'],
      photoURL: map['photoURL'],
      isTrueOrFalse: map['isTrueOrFalse'],
    );
  }
}
