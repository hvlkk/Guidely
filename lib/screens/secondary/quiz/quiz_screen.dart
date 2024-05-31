import 'package:flutter/material.dart';
import 'package:guidely/models/data/quiz/quiz.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quiz});

  final Quiz quiz;

  @override
  _QuizScreenState createState() => _QuizScreenState();
}


class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < widget.quiz.quizItems.length - 1) {
        _currentQuestionIndex++;
      } else {
        // Handle end of quiz
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quiz.quizItems[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Page ${_currentQuestionIndex + 1}/${widget.quiz.quizItems.length}'),
      ),
      body: currentQuestion.isTrueOrFalse
          ? TrueFalseQuestion(
              question: currentQuestion.question,
              image: currentQuestion.photoURL,
              correctAnswer: currentQuestion.correctAnswer == 'true' ? true : false,
              onNext: _nextQuestion,
            )
          : MultipleChoiceQuestion(
              question: currentQuestion.question,
              image: currentQuestion.photoURL,
              options: currentQuestion.options,
              correctAnswer: currentQuestion.correctAnswer,
              onNext: _nextQuestion,
            ),
    );
  }
}

class TrueFalseQuestion extends StatelessWidget {
  final String question;
  final String image;
  final bool correctAnswer;
  final VoidCallback onNext;

  TrueFalseQuestion({
    required this.question,
    required this.image,
    required this.correctAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.asset(image),
          Text(
            question,
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Handle true answer
              onNext();
            },
            child: Text('True'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle false answer
              onNext();
            },
            child: Text('False'),
          ),
        ],
      ),
    );
  }
}

class MultipleChoiceQuestion extends StatelessWidget {
  final String question;
  final String image;
  final List<String> options;
  final int correctAnswer;
  final VoidCallback onNext;

  MultipleChoiceQuestion({
    required this.question,
    required this.image,
    required this.options,
    required this.correctAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.asset(image),
          Text(
            question,
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ...options.map((option) {
            return ElevatedButton(
              onPressed: () {
                // Handle option selection
                onNext();
              },
              child: Text(option),
            );
          }).toList(),
        ],
      ),
    );
  }
}