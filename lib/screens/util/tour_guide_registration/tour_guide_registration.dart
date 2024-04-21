import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/screens/util/tour_guide_registration/tour_guide_registration_screen_second.dart';
import 'package:guidely/screens/util/tour_guide_registration/tour_registration_template.dart';

class TourGuideRegistrationScreen extends StatelessWidget {
  TourGuideRegistrationScreen({super.key});

  final _descKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return RegistrationScreenTemplate(
      title: 'Tour Guide Registration',
      step: 'Step 1: Background and Motivation',
      instruction:
          'We would like to know more about you. Please share some key details about yourself, including why you want to become a tour guide, and whether you have any prior experience in the field.',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              key: _descKey,
              decoration: const InputDecoration(
                hintText: 'Enter your description here',
                border: OutlineInputBorder(),
                fillColor: MainColors.textHint,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'You must enter a description.';
                }
                return null;
              },
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(ButtonColors.primary),
            ),
            onPressed: () {
              // TODO: needs to verify that the description is not empty
              // TODO: we need to pass the description to the next screen?
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const TourGuideRegistrationScreenSecond(),
                ),
              );
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
