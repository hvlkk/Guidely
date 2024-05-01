// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/data/registration_data.dart';
import 'package:guidely/models/data/tour_event_location.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/models/utils/language.dart';
import 'package:guidely/screens/main/tour_details.dart';
import 'package:guidely/screens/util/notifications.dart';
import 'package:guidely/widgets/entities/tour_list_item.dart';

class ToursHomeScreen extends StatefulWidget {
  const ToursHomeScreen({super.key});

  @override
  _ToursHomeScreenState createState() => _ToursHomeScreenState();
}

// needs refactoring to use Riverpod

class _ToursHomeScreenState extends State<ToursHomeScreen> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;

  List<Tour> tours = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final userData = snapshot.data!;
          final finalJsonData = userData.data()?.entries;

          if (finalJsonData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final jsonDataMap = Map<String, dynamic>.fromEntries(finalJsonData);

          final username = jsonDataMap['username'];
          final imageUrl = jsonDataMap['imageUrl'];

          // TEMP CODE FOR DEBUGGING
          RegistrationData registrationData = RegistrationData(
            uid: 'registration123',
            description: 'This is a registration description.',
            uploadedIdURL: 'https://example.com/registration.jpg',
          );

          // Create an instance of User using the default constructor
          var user1 = User(
            uid: 'user123',
            username: 'exampleUser',
            email: 'user@example.com',
            imageUrl: 'https://example.com/image.jpg',
            registrationData: registrationData,
          );

          var user2 = User(
            uid: 'user456',
            username: 'exampleUser2',
            email: 'user2@example.com',
            imageUrl: 'https://example.com/image2.jpg',
            registrationData: registrationData,
          );

          var tour1 = Tour(
            title: 'The hidden gem',
            area: 'Acropolis',
            description:
                'Embark on an unforgettable journey through time as you explore the ancient marvels of the Acropolis in Athens. Immerse yourself in the rich history and culture of Greece as you wander through iconic landmarks such as the Parthenon, Erechtheion, and Temple of Athena Nike. Marvel at the stunning architectural brilliance of these ancient wonders, each telling its own story of the glorious past of Athens. As you stroll along the marble pathways, guided by knowledgeable experts, let the breathtaking views of the city below and the majestic ruins above transport you to a bygone era. This tour promises an awe-inspiring experience that will leave you with a profound appreciation for the enduring legacy of ancient Greece.',
            duration: const Duration(hours: 2, minutes: 30),
            images: ['assets/images/tours/tour1.jpg'],
            languages: [const Language(name: 'English', code: 'gb')],
            startLocation: const TourEventLocation(
              name: 'Start Location',
              address: 'Acropolis, Athens',
              latitude: 37.9838,
              longitude: 23.7275,
            ),
            locations: [],
            organizer: user1,
          );

          var tour2 = Tour(
            title: 'Free Tour of Essentials',
            area: 'Utrecht',
            description: 'Tour Description...',
            duration: const Duration(hours: 1, minutes: 30),
            images: [
              'assets/images/tours/tour2.jpg',
              'assets/images/tours/tour1.jpg'
            ],
            languages: [
              const Language(name: 'English', code: 'gb'),
              const Language(name: 'German', code: 'de')
            ],
            startLocation: const TourEventLocation(
              name: 'Start Location',
              address: 'Start Address',
              latitude: 37.9838,
              longitude: 23.7275,
            ),
            locations: [],
            organizer: user2,
          );

          tours.add(tour1);
          tours.add(tour2);
          tours.add(tour1);
          tours.add(tour2);
          tours.add(tour1);
          // TEMP CODE FOR DEBUGGING

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Guidely',
                style: TextStyle(
                  fontFamily: poppinsFont.fontFamily,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Welcome, $username!',
                          style: TextStyle(
                            fontFamily: poppinsFont.fontFamily,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: const Icon(Icons.notifications, size: 30),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) {
                                  return const NotificationsScreen();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for tours',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    height: 450,
                    child: ListView.builder(
                      itemCount: tours.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to a new page when the TourListItem is tapped
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TourDetailsScreen(
                                    tour: tours[index],
                                  ),
                                ),
                              );
                            },
                            child: TourListItem(
                              tour: tours[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
