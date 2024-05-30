import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/screens/util/quiz_creator/components/multiple_choice_component.dart';
import 'package:guidely/screens/util/quiz_creator/components/single_choice_component.dart';
import 'package:guidely/widgets/customs/custom_switch.dart';
import 'package:image_picker/image_picker.dart';

class QuizCreatorScreen extends StatefulWidget {
  QuizCreatorScreen({super.key});

  List<String> answers = [];

  @override
  State<QuizCreatorScreen> createState() => _QuizCreatorScreenState();
}

class _QuizCreatorScreenState extends State<QuizCreatorScreen> {
  var selectedImage;
  final _tourTitleController = TextEditingController();

  bool _isMultipleChoice = false;

  void _handleSwitchChange(bool value) {
    setState(() {
      _isMultipleChoice = value;
    });
  }

  void _addCustomAnswer(String name) {
    // this will need to update to allow for custom answers names
    setState(() {
      widget.answers.add(name);
    });
  }

  void _showInputDialog() {
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
                setState(() {
                  _addCustomAnswer(_answerController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // make a form to create a quiz, this will have
    // the title of the quiz, a questions, a set of options and the correct answer

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Quiz"),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Title', // create a quiz for this tour text
              style: TextStyle(fontSize: 20),
            ),
            // image input
            Padding(
              padding: const EdgeInsets.all(15.0),
              // todo : separate to image picker component
              child: selectedImage == null
                  ? GestureDetector(
                      child: const Card(
                        child: Padding(
                          padding: EdgeInsets.all(25.0),
                          child: Text(
                            'Upload an image to be shown to the quiz',
                            style: TextStyle(color: MainColors.textHint),
                          ),
                        ),
                      ),
                      onTap: () async => {
                        _pickImage(),
                      },
                    )
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Image.file(
                              File(selectedImage!.path),
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Uploaded Image',
                              style: TextStyle(color: MainColors.textHint),
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
            // format input
            CustomSwitch(onChanged: _handleSwitchChange),
            // _isMultipleChoice
            //     ? MultipleChoiceComponent()
            //     : SingleChoiceComponent(),
            ElevatedButton(
              onPressed: _showInputDialog,
              child: const Text('Add Answer'),
            ),
            // Displaying the answers
            Expanded(
              child: ListView.builder(
                itemCount: widget.answers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.answers[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 150,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }
}
