import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guidely/models/data/quiz/quiz.dart';
import 'package:guidely/models/data/quiz/quiz_item.dart';
import 'package:guidely/screens/secondary/quiz/components/quiz_results_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quiz, required this.sessionId});

  final Quiz quiz;
  final String sessionId;

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedOption;
  String? _correctOption;
  bool? _isCorrect;
  int correctAnswers = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeQuizProgress();
  }

  Future<void> _initializeQuizProgress() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference<Map<String, dynamic>> quizDocRef = FirebaseFirestore
        .instance
        .collection('sessions')
        .doc(widget.sessionId)
        .collection('quizzes')
        .doc(userId);

    final snapshot = await quizDocRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        _currentQuestionIndex = data['currentQuestionIndex'];
        correctAnswers = data['correctAnswers'];
      });
      if (_currentQuestionIndex >= widget.quiz.quizItems.length) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              correctAnswers: correctAnswers,
              totalQuestions: widget.quiz.quizItems.length,
            ),
          ),
        );
      }
    } else {
      await quizDocRef.set({
        'userId': userId,
        'correctAnswers': 0,
        'currentQuestionIndex': 0,
        'totalQuestions': widget.quiz.quizItems.length,
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateQuizProgress() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final quizDocRef = FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionId)
        .collection('quizzes')
        .doc(userId);

    _currentQuestionIndex++;
    await quizDocRef.update({
      'correctAnswers': correctAnswers,
      'currentQuestionIndex': _currentQuestionIndex,
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < widget.quiz.quizItems.length - 1) {
        _selectedOption = null;
        _correctOption = null;
        _isCorrect = null;
        _updateQuizProgress();
      } else {
        // update for the last question
        _updateQuizProgress();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              correctAnswers: correctAnswers,
              totalQuestions: widget.quiz.quizItems.length,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final QuizItem currentQuizItem =
        widget.quiz.quizItems[_currentQuestionIndex];
    final String appBarText =
        currentQuizItem.isTrueOrFalse ? "True/False" : "Multiple Choice";

    Color getButtonColor(String option) {
      if (_isCorrect == null && _selectedOption == option) {
        return Colors.orange; // Selected option before pressing "Continue"
      }
      if (option == _correctOption) {
        return Colors.green; // Correct option after pressing "Continue"
      }
      if (option == _selectedOption && _isCorrect == false) {
        return Colors
            .red; // Incorrect selected option after pressing "Continue"
      }
      return Colors.white;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${widget.quiz.quizItems.length} - $appBarText',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.quizItems.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                currentQuizItem.question,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            if (currentQuizItem.photoURL.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Image.network(
                  currentQuizItem.photoURL,
                  fit: BoxFit.cover,
                  height: 200,
                ),
              ),
            const Spacer(),
            if (!currentQuizItem.isTrueOrFalse)
              Column(
                children: [
                  for (final option in currentQuizItem.options)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getButtonColor(option),
                          foregroundColor: Colors.black,
                          side:
                              const BorderSide(color: Colors.orange, width: 2),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedOption = option;
                          });
                        },
                        child: Text(option),
                      ),
                    ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getButtonColor('False'),
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.orange, width: 2),
                        minimumSize: const Size(100, 250),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedOption = 'False';
                        });
                      },
                      child: const Text('False'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getButtonColor('True'),
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.orange, width: 2),
                        minimumSize: const Size(100, 250),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedOption = 'True';
                        });
                      },
                      child: const Text('True'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                bool isCorrect = false;
                String correctOption =
                    currentQuizItem.options[currentQuizItem.correctAnswer];

                if (!currentQuizItem.isTrueOrFalse) {
                  isCorrect = _selectedOption == correctOption;
                } else {
                  isCorrect = (_selectedOption == 'True' &&
                          correctOption == 'True') ||
                      (_selectedOption == 'False' && correctOption == 'False');
                }

                if (isCorrect) {
                  correctAnswers++;
                }

                // Update correctness state and correct option
                setState(() {
                  _isCorrect = isCorrect;
                  _correctOption = correctOption;
                });

                // Move to the next question after 2 seconds
                Future.delayed(const Duration(seconds: 2), _nextQuestion);
              },
              child: const Text('Continue'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
