// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/location_service.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/providers/tours_provider.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:guidely/screens/util/notifications.dart';
import 'package:guidely/tour_filter_service.dart';
import 'package:guidely/widgets/customs/custom_map.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item.dart';

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

    late List<Tour> tourDataUnfiltered;

    final tourDataFiltered = tourDataAsyncUnfiltered.when(
      data: (tours) {
        tourDataUnfiltered = tours;
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
        tourDataFiltered.map((tour) => tour.tourDetails.waypoints![0]).toList();

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

          final _searchScreenController = TextEditingController();
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
                    padding: const EdgeInsets.all(25),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchScreenController,
                            decoration: InputDecoration(
                              hintText: 'Search for tours',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          child: Icon(Icons.search),
                          onTap: () {
                            // Search for tours based on the search bar input
                            final filteredTours =
                                TourFilterService.filterSearchBar(
                              _searchScreenController.text,
                              tourDataUnfiltered,
                            );
                            print(filteredTours);
                            // TODO - Display the filtered tours
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: SizedBox(
                        width: 335,
                        height: 300,
                        child: tourDataFiltered.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : CustomMap(
                                waypoints: startLocations,
                                withTrail: false,
                                onTapWaypoint: (LatLng p0) {
                                  // Find the tour corresponding to the tapped waypoint
                                  final selectedTour =
                                      tourDataFiltered.firstWhere(
                                    (tour) =>
                                        tour.tourDetails.waypoints![0]
                                                .latitude ==
                                            p0.latitude &&
                                        tour.tourDetails.waypoints![0]
                                                .longitude ==
                                            p0.longitude,
                                  );
                                  // Display a card with the tour details
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: SingleChildScrollView(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Tour Details',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Tour Name: ${selectedTour.tourDetails.title}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Tour Description: ${selectedTour.tourDetails.description}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Tour Duration: ${selectedTour.tourDetails.startTime}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Tour Start Date: ${selectedTour.tourDetails.startDate}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 15),
                                              GestureDetector(
                                                child: const Text(
                                                  'Learn more',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: MainColors.accent,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          TourDetailsScreen(
                                                        tour: selectedTour,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 20),
                                              Align(
                                                alignment: Alignment.center,
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    'Close',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
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
                  const SizedBox(width: 15),
                  SizedBox(
                    height: 450,
                    child: tourDataFiltered.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: tourDataFiltered.length,
                            itemBuilder: (BuildContext context, int index) {
                              final tour = tourDataFiltered[index];
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
