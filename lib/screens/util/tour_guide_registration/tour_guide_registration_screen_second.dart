// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/data/registration_data.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/screens/util/tour_guide_registration/tour_registration_template.dart';
import 'package:guidely/widgets/user_image_picker_widget.dart';
import 'package:guidely/models/entities/user.dart' as myuser;
import 'package:image_picker/image_picker.dart'; // alias to avoid conflicts

class TourGuideRegistrationScreenSecond extends ConsumerStatefulWidget {
  const TourGuideRegistrationScreenSecond({
    super.key,
    required this.description,
  });

  final String description;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TourGuideRegistrationScreenSecondState();
  }
}

class _TourGuideRegistrationScreenSecondState
    extends ConsumerState<TourGuideRegistrationScreenSecond> {
  XFile? selectedImage;

  void _submitRegistration(BuildContext context, myuser.User user) async {
    RegistrationData registrationData = RegistrationData(
      uid: user.uid,
      description: widget.description,
      uploadedIdURL: '',
    );

    final updatedUser = user.copyWith(
      isTourGuide: true,
      registrationData: registrationData,
      bookedTours: [],
      organizedTours: [],
    );

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return RegistrationScreenTemplate(
          title: 'Tour Guide Registration',
          step: 'Step 2: ID Submission',
          instruction:
              'In order to confirm your identity, we require a copy of your ID. Our team will examine its validity and get back to you within 3 business days. Don’t worry, your data will stay safe and private.',
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: selectedImage == null
                    ? GestureDetector(
                        child: const Card(
                          child: Padding(
                            padding: EdgeInsets.all(25.0),
                            child: Text(
                              'Please upload a copy of your ID. \nThis can be a passport, driver’s license, or any other government-issued ID.',
                              style: TextStyle(color: MainColors.textHint),
                            ),
                          ),
                        ),
                        onTap: () async => {
                          selectedImage = await ImagePicker().pickImage(
                              source: ImageSource.gallery, maxWidth: 150),
                          setState(() {
                            selectedImage = selectedImage;
                          })
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
                  backgroundColor:
                      MaterialStateProperty.all(ButtonColors.primary),
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
      },
    );
  }
}
