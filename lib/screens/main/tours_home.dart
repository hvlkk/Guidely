// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guidely/location_service.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/providers/tours_provider.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:guidely/screens/util/notifications.dart';
import 'package:guidely/widgets/customs/custom_map.dart';
import 'package:guidely/widgets/entities/tour_list_item.dart';

class ToursHomeScreen extends ConsumerStatefulWidget {
  const ToursHomeScreen({super.key});

  @override
  _ToursHomeScreenState createState() => _ToursHomeScreenState();
}

class _ToursHomeScreenState extends ConsumerState<ToursHomeScreen> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots();

    // get user's location
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      SnackBar(content: Text('Error: $e'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final tourDataAsyncUnfiltered = ref.watch(
        toursStreamProvider); // listens for changes in the toursStreamProvider,
    // this will not re-fetch the data from the database if the data is already available

    final tourData = tourDataAsyncUnfiltered.when(
      data: (tours) {
        if (_currentPosition != null) {
          final closestTours = LocationService.findClosestToursToPosition(
            tours,
            _currentPosition!,
            3, // Get the 3 closest tours
          );
          return closestTours;
        } else {
          return <Tour>[];
        }
      },
      loading: () => List<Tour>.empty(),
      error: (error, stackTrace) => List<Tour>.empty(),
    );

    final startLocations =
        tourData.map((tour) => tour.tourDetails.waypoints![0]).toList();

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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: SizedBox(
                      width: 335,
                      height: 300,
                      child: tourData.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : CustomMap(
                              waypoints: startLocations,
                              withTrail: false,
                            ),
                    ),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          'Tours Nearby:',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 450,
                    child: tourData.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: tourData.length,
                            itemBuilder: (BuildContext context, int index) {
                              final tour = tourData[index];
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigate to a new page when the TourListItem is tapped
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TourDetailsScreen(
                                          tour: tour,
                                        ),
                                      ),
                                    );
                                  },
                                  child: TourListItem(
                                    tour: tour,
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
