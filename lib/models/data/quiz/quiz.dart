import 'package:guidely/models/data/quiz/quiz_item.dart';
import 'package:uuid/uuid.dart';

class Quiz {
  final List<QuizItem> quizItems;
  final String id = const Uuid().v4();

  Quiz({required this.quizItems});
}
