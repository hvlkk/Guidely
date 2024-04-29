// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/data/tour_event_location.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/utils/language.dart';
import 'package:guidely/screens/util/notifications.dart';
import 'package:guidely/widgets/tour_list_item.dart';

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
          const tour1 = Tour(
            title: 'The hidden gem',
            area: 'Acropolis',
            description: 'Tour Description...',
            duration: Duration(hours: 2, minutes: 30),
            images: ['assets/images/tours/tour1.jpg'],
            languages: [Language(name: 'English', code: 'gb')],
            startLocation: TourEventLocation(
              name: 'Start Location',
              address: 'Start Address',
              latitude: 0,
              longitude: 0,
            ),
            locations: [],
            // organizer: username,
          );

          const tour2 = Tour(
            title: 'Free Tour of Essentials',
            area: 'Utrecht',
            description: 'Tour Description...',
            duration: Duration(hours: 1, minutes: 30),
            images: ['assets/images/tours/tour2.jpg'],
            languages: [Language(name: 'English', code: 'gb'), Language(name: 'German', code: 'de')],
            startLocation: TourEventLocation(
              name: 'Start Location',
              address: 'Start Address',
              latitude: 0,
              longitude: 0,
            ),
            locations: [],
            // organizer: username,
          );

          tours.add(tour1);
          tours.add(tour2);
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
                  // ListView.builder(
                  //   itemCount: items.length,
                  //   itemBuilder: (BuildContext context, int index) {
                  //     return Padding(
                  //       padding: const EdgeInsets.all(8),
                  //       child: TourListItem(tour: items[index]),
                  //     );
                  //   },
                  // ),
                  const TourListItem(
                    tour: tour1,
                  ),
                  const SizedBox(height: 15),
                  const TourListItem(
                    tour: tour2,
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
