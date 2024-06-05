// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guidely/models/data/activity.dart';
import 'package:guidely/models/data/tour_creation_data.dart';
import 'package:guidely/models/entities/notification.dart' as myNoti;
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart' as TourUser;
import 'package:guidely/models/enums/tour_guide_auth_state.dart';
import 'package:guidely/models/utils/language.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator_template.dart';
import 'package:guidely/services/general/image_retrieval_service.dart';
import 'package:uuid/uuid.dart';

// TODO: Clean

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
              for (final language in languages)
                GestureDetector(
                  onTap: () {
                    bool exists = widget.activeLanguages.contains(language);
                    setState(() {
                      if (exists) {
                        widget.activeLanguages.remove(language);
                      } else {
                        widget.activeLanguages.add(language);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 2), // Adjust padding as needed
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.activeLanguages.contains(language)
                              ? Colors.blue
                              : Colors.transparent,
                          width: 1, // Adjust the border width if needed
                        ),
                        borderRadius: BorderRadius.circular(
                            15), // Adjust the border radius
                      ),
                      child: CircleAvatar(
                        radius:
                            20, // Adjust the radius to make the avatar smaller
                        backgroundImage: AssetImage(
                          'icons/flags/png250px/${language.code}.png',
                          package: 'country_icons',
                        ),
                      ),
                    ),
                  ),
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

  Future<void> _uploadData() async {
    final finalData = widget.tourData.copyWith(
      activities: widget.activeActivities,
      languages: widget.activeLanguages,
    );

    final currentUser = FirebaseAuth.instance.currentUser;

    final uid = currentUser?.uid;
    Map<String, dynamic>? userData = {};
    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      userData = docSnapshot.data();
    } catch (e) {
      const SnackBar(
        content: Text('Failed to get user data'),
      );
    }

    final user = TourUser.User(
      uid: userData?['uid'] ?? '',
      username: userData?['username'] ?? '',
      email: userData?['email'] ?? '',
      imageUrl: userData?['imageUrl'] ?? '',
      authState: TourGuideAuthState.values[userData?['authState'] ?? 0],
      bookedTours: List<String>.from(userData?['bookedTours'] ?? []),
      fcmToken: userData?['fcmToken'] ?? '',
      organizedTours: List<String>.from(userData?['organizedTours'] ?? []),
      notifications: List<myNoti.Notification>.from(
        userData?['notifications']
                ?.map((item) => myNoti.Notification.fromMap(item)) ??
            [],
      ),
      dateJoined: userData?['dateJoined'] != null
          ? DateTime.parse(userData?['dateJoined'])
          : null,
      dateOfBirth: userData?['dateOfBirth'] != null
          ? DateTime.parse(userData?['dateOfBirth'])
          : null,
    );

    if (currentUser == null) {
      return;
    }

    ImageRetrievalService imageRetrievalService = ImageRetrievalService();

    final fetchedImages = await imageRetrievalService.fetchCityImagesList(
      finalData.title,
    );

    final tour = Tour(
      uid: const Uuid().v4(),
      tourDetails: finalData,
      organizer: user,
      images: fetchedImages,
      reviews: [],
      state: TourState.upcoming,
      registeredUsers: [],
      creationDate: DateTime.now(),
    );

    user.organizedTours.add(tour.uid);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());

    FirebaseFirestore.instance
        .collection('tours')
        .doc(tour.uid)
        .set(tour.toMap());

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );

    // add a snackbar to show that the tour has been created
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tour has been created'),
      ),
    );
  }
}
