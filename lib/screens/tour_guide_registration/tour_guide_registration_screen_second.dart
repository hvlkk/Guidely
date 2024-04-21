import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/screens/tour_guide_registration/tour_registration_template.dart';

class TourGuideRegistrationScreenSecond extends StatelessWidget {
  const TourGuideRegistrationScreenSecond({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationScreenTemplate(
      title: 'Tour Guide Registration',
      step: 'Step 2: ID Submission',
      instruction:
          'In order to confirm your identity, we require a copy of your ID. Our team will examine its validity and get back to you within 3 business days. Don’t worry, your data will stay safe and private.',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Text(
                    'Please upload a copy of your ID. \nThis can be a passport, driver’s license, or any other government-issued ID.',
                    style: TextStyle(color: MainColors.textHint),
                  ),
                ),
              ),
              onTap: () => {
                //TODO: add a function to upload the ID
              },
            ),
          ),
          const Row(
            children: [
              Expanded(
                child: Divider(
                  color: MainColors.textHint,
                  thickness: 0.5,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'or',
                  style: TextStyle(color: MainColors.textHint),
                ),
              ),
              Expanded(
                child: Divider(
                  color: MainColors.textHint,
                  thickness: 0.5,
                ),
              ),
            ],
          ),

          // add a button to let the user take a photo of their ID
          const SizedBox(height: 25),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey),
            ),
            onPressed: () {
              // add a function to take a photo of the ID
            },
            child: const Text('Take a photo',
                style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(ButtonColors.primary),
            ),
            onPressed: () {
              // add a function to submit the ID
            },
            child: const Text('Submit', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
