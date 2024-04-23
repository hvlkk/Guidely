import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/main.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/registration_data.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/screens/util/tour_guide_registration/tour_registration_template.dart';
import 'package:guidely/widgets/user_image_picker_widget.dart';
import 'package:guidely/models/user.dart' as myuser; // alias to avoid conflicts

class TourGuideRegistrationScreenSecond extends ConsumerWidget {
  const TourGuideRegistrationScreenSecond(
      {super.key, required this.description});

  final String description;

  void _submitRegistration(BuildContext context, myuser.User user) async {
    // we will prefer to use the copyWith method to update the user object rather than directly modifying it
    // to ensure immutability and avoid side effects
    RegistrationData registrationData = RegistrationData(
      uid: user.uid,
      description: description,
      uploadedIdURL: '',
    );

    final updatedUser =
        user.copyWith(isTourGuide: true, registrationData: registrationData);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .set(
        {
          'isTourGuide': true,
          'registrationData': registrationData.toJson(),
        },
        SetOptions(merge: true), // Merge with existing data
      );
    } catch (error) {
      // handle the error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
    // TODO: this needs to return the user to the home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainApp(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const Text(
            'Take a photo',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),

          UserImagePickerWidget(
            onImagePicked: (pickedImage) {
              // Handle the picked image here
            },
            radius: 80,
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(ButtonColors.primary),
            ),
            onPressed: () {
              final user = ref.read(userDataProvider);
              user.when(
                data: (userData) {
                  _submitRegistration(context, userData);
                },
                loading: () {},
                error: (_, __) {},
              );
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
