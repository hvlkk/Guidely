import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/screens/util/tour_guide_registration/tour_guide_registration_screen_second.dart';
import 'package:guidely/screens/util/tour_guide_registration/tour_registration_template.dart';

class TourGuideRegistrationScreen extends StatelessWidget {
  TourGuideRegistrationScreen({super.key});

  // create a controller for the description
  final TextEditingController _descController = TextEditingController();

  void _submit(BuildContext context) {
    final text = _descController.text;

    final isValid = text.trim().isNotEmpty && text.length > 10;

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please enter a valid description, at least 10 characters long.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TourGuideRegistrationScreenSecond(
          description: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationScreenTemplate(
      title: 'Tour Guide Registration',
      step: 'Step 1: Background and Motivation',
      instruction:
          'We would like to know more about you. Please share some key details about yourself, including why you want to become a tour guide, and whether you have any prior experience in the field.',
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter your description here',
                  border: OutlineInputBorder(),
                  fillColor: MainColors.textHint,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                controller: _descController,
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(ButtonColors.primary),
              ),
              onPressed: () {
                _submit(context);
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
