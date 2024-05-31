import 'package:guidely/models/data/quiz/quiz_item.dart';
import 'package:uuid/uuid.dart';

class Quiz {
  final List<QuizItem> quizItems;
  final String id = const Uuid().v4();

  Quiz({required this.quizItems});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizItems': quizItems.map((item) => item.toMap()).toList(),
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      quizItems: List<QuizItem>.from(
        map['quizItems'].map((item) => QuizItem.fromMap(item)),
      ),
    );
  }
}
