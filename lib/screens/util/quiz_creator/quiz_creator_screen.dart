import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guidely/models/data/quiz/quiz.dart';
import 'package:guidely/models/data/quiz/quiz_item.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/services/business_layer/tour_service.dart';
import 'package:guidely/services/general/firebase_storage_service.dart';
import 'package:guidely/widgets/customs/custom_switch.dart';
import 'package:image_picker/image_picker.dart';

class QuizCreatorScreen extends StatefulWidget {
  const QuizCreatorScreen({
    super.key,
    required this.tour,
  });

  final Tour tour;

  @override
  State<QuizCreatorScreen> createState() => _QuizCreatorScreenState();
}

class _QuizCreatorScreenState extends State<QuizCreatorScreen> {
  final FirebaseStorageService _storageService = FirebaseStorageService();
  var selectedImage;
  final _tourTitleController = TextEditingController();
  bool _isMultipleChoice = true;
  List<String> answers = [];
  String answerLimitMessage = '';
  bool isTrueCorrect = true;
  bool isFalseCorrect = false;
  int correctAnswerIndex = -1;
  var imageUrl;

  List<QuizItem> quizItems = [];

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 150,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void _handleSwitchChange(bool value) {
    if (mounted) {
      setState(() {
        _isMultipleChoice = value;
        // Update answers based on switch change
        if (!_isMultipleChoice) {
          answers = ['True', 'False'];
          correctAnswerIndex = isTrueCorrect ? 0 : (isFalseCorrect ? 1 : -1);
        } else {
          answers.clear();
          isTrueCorrect = false; // Reset True as correct answer
          isFalseCorrect = false; // Reset False as correct answer
          correctAnswerIndex =
              -1; // Reset correct answer index for multiple-choice
        }
        answerLimitMessage = '';
      });
    }
  }

  void _addCustomAnswer() {
    TextEditingController _answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter your answer'),
          content: TextField(
            controller: _answerController,
            decoration: const InputDecoration(hintText: "Enter answer here"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                if (mounted) {
                  _addAnswer(_answerController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addAnswer(String name) {
    // Ensure there are no more than 4 answers for multiple-choice questions
    if (_isMultipleChoice && answers.length < 4 && mounted) {
      setState(() {
        answers.add(name);
        if (answers.length == 4) {
          answerLimitMessage =
              'You have added the maximum number of answers (4).';
        }
      });
    } else if (_isMultipleChoice && answers.length >= 4 && mounted) {
      setState(() {
        answerLimitMessage = 'You can only add up to 4 answers.';
      });
    }
  }

  void _addQuizToFirebase(Quiz quiz) async {
    TourService.updateTourData(widget.tour.uid, {
      'quizzes': FieldValue.arrayUnion([quiz.toMap()])
    });
  }

  void _getImageUrl() async {
    String tempimageUrl = await _storageService.uploadImage(
        selectedImage, "quiz_images", widget.tour.uid);
    setState(() {
      imageUrl = tempimageUrl;
    });
  }

  void _handleNext() {
    String question = _tourTitleController.text;
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
      return;
    }

    if (correctAnswerIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a correct answer')),
      );
      return;
    }

    _getImageUrl();

    QuizItem newQuizItem = QuizItem(
      question: question,
      options: answers,
      correctAnswer: correctAnswerIndex,
      photoURL: imageUrl,
      isTrueOrFalse: !_isMultipleChoice,
    );

    setState(() {
      quizItems.add(newQuizItem);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiz item added successfully')),
    );

    // Show dialog to ask if user wants to add more quiz items
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Item Added'),
          content: const Text('Do you want to add another quiz item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                // create a quiz
                Quiz quiz = Quiz(quizItems: quizItems);
                // add this quiz to firebase
                _addQuizToFirebase(quiz);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset the form
                if (mounted) {
                  setState(() {
                    _tourTitleController.clear();
                    selectedImage = null;
                    _isMultipleChoice = false;
                    answers = ['True', 'False'];
                    answerLimitMessage = '';
                    isTrueCorrect = false;
                    isFalseCorrect = false;
                    correctAnswerIndex = -1;
                  });
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Quiz"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget.tour.tourDetails.title,
                  style: const TextStyle(fontSize: 20),
                ),
                // Image input
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: selectedImage == null
                      ? GestureDetector(
                          child: const Card(
                            child: Padding(
                              padding: EdgeInsets.all(25.0),
                              child: Text(
                                'Upload an image to be shown to the quiz',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          onTap: _pickImage,
                        )
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Image.file(
                                  File(selectedImage.path),
                                  width: 250,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Uploaded Image',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      hintText: 'Enter the question',
                      border: OutlineInputBorder(),
                    ),
                    controller: _tourTitleController,
                  ),
                ),
                // Format input
                CustomSwitch(onChanged: _handleSwitchChange),
                // Show add answer button only for multiple-choice questions
                if (_isMultipleChoice && answers.length < 4)
                  ElevatedButton(
                    onPressed: _addCustomAnswer,
                    child: const Text('Add Answer'),
                  ),
                if (answerLimitMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      answerLimitMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                // Displaying the answers
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    if (!_isMultipleChoice) {
                      return ListTile(
                        title: Row(
                          children: [
                            Radio(
                              value: index,
                              groupValue: isTrueCorrect ? 0 : 1,
                              onChanged: (value) {
                                setState(() {
                                  if (value == 0) {
                                    isTrueCorrect = true;
                                    isFalseCorrect = false;
                                    correctAnswerIndex = 0;
                                  } else {
                                    isTrueCorrect = false;
                                    isFalseCorrect = true;
                                    correctAnswerIndex = 1;
                                  }
                                });
                              },
                            ),
                            Text(answers[index]),
                          ],
                        ),
                      );
                    } else {
                      return ListTile(
                        title: Row(
                          children: [
                            Radio(
                              value: index,
                              groupValue: correctAnswerIndex,
                              onChanged: (value) {
                                setState(() {
                                  correctAnswerIndex = value as int;
                                });
                              },
                            ),
                            Text(answers[index]),
                          ],
                        ),
                      );
                    }
                  },
                ),
                // Show message for adding answers
                if (_isMultipleChoice && answers.length < 4)
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'You can add up to 4 possible answers.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                // Next button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
