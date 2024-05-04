// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/data/activity.dart';
import 'package:guidely/models/data/tour_creation_data.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/utils/language.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator_template.dart';
import 'package:guidely/models/entities/user.dart'
    // ignore: library_prefixes
    as TourUser; // Renamed to avoid conflict with FirebaseAuth

class TourCreatorThirdScreen extends StatefulWidget {
  TourCreatorThirdScreen({super.key, required this.tourData});

  List<Activity> activities = [];
  List<Language> languages = [];

  List<Activity> activeActivities = [];
  List<Language> activeLanguages = [];

  final TourCreationData tourData;

  @override
  State<TourCreatorThirdScreen> createState() => _TourCreatorThirdScreenState();
}

class _TourCreatorThirdScreenState extends State<TourCreatorThirdScreen> {
  void initialize() {
    widget.activities = [
      Activity(name: 'Walking tour'),
      Activity(name: 'Museum tour'),
      Activity(name: "Children's tour"),
      Activity(name: "Cycling tour"),
      Activity(name: 'Hiking'),
      Activity(name: 'City sightseeing'),
      Activity(name: 'Nature walk'),
    ];

    widget.languages = const [
      Language(name: 'German', code: 'de'),
      Language(name: 'English', code: 'gb'),
      Language(name: 'Spanish', code: 'es'),
      Language(name: 'French', code: 'fr'),
      Language(name: 'Italian', code: 'it'),
    ];
  }

  void addCustomActivity(String name) {
    // this will need to update to allow for custom activity names
    setState(() {
      widget.activities.add(Activity(name: name));
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return TourCreatorTemplate(
      title: 'Tour Creation',
      body: Column(
        children: [
          const Center(
            child: Text(
              'Activities',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (Activity activity in widget.activities)
            CheckboxListTile(
              title: Text(activity.name),
              value: activity.isSelected,
              onChanged: (value) {
                setState(
                  () {
                    activity.isSelected = value!;
                    bool exists = widget.activeActivities.contains(activity);

                    setState(() {
                      if (exists) {
                        widget.activeActivities.remove(activity);
                      } else {
                        widget.activeActivities.add(activity);
                      }
                    });
                  },
                );
              },
            ),
          TextButton(
            onPressed: () {
              addCustomActivity('New Activity');
            },
            child: Text(
              'Add a new activity',
              style: poppinsFont.copyWith(
                color: MainColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Languages',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final language in widget.languages)
                Row(
                  children: [
                    GestureDetector(
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(
                            'icons/flags/png250px/${language.code}.png',
                            package: 'country_icons',
                          ),
                        ),
                        onTap: () {
                          bool exists =
                              widget.activeLanguages.contains(language);
                          setState(() {
                            if (exists) {
                              widget.activeLanguages.remove(language);
                            } else {
                              widget.activeLanguages.add(language);
                            }
                          });
                        }),
                    const SizedBox(width: 15),
                  ],
                ),
            ],
          ),
        ],
      ),
      isFinal: true,
      callBack: () {
        _uploadData();
      },
    );
  }

  void _uploadData() {
    final finalData = widget.tourData.copyWith(
      activities: widget.activeActivities,
      languages: widget.activeLanguages,
    );

    final currentUser = FirebaseAuth.instance.currentUser;

    final user = TourUser.User(
      uid: currentUser?.uid ?? '',
      username: currentUser?.displayName ?? '',
      email: currentUser?.email ?? '',
      imageUrl: currentUser?.photoURL ?? '',
    );

    if (currentUser == null) {
      return;
    }

    final tour = Tour(
      tourDetails: finalData,
      organizer: user,
    );

    FirebaseFirestore.instance.collection('tours').add(tour.toMap());

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }
}
