// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/notification.dart' as myNoti;
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/providers/tours_provider.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:guidely/screens/util/notifications.dart';
import 'package:guidely/screens/util/tour_details_dialog.dart';
import 'package:guidely/screens/util/tour_filter_dropdown.dart';
import 'package:guidely/utils/location_finder.dart';
import 'package:guidely/utils/tour_filter.dart';
import 'package:guidely/widgets/customs/custom_map.dart';
import 'package:guidely/widgets/customs/custom_notification_icon.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item.dart';

class ToursHomeScreen extends ConsumerStatefulWidget {
  const ToursHomeScreen({super.key});

  @override
  _ToursHomeScreenState createState() => _ToursHomeScreenState();
}

class _ToursHomeScreenState extends ConsumerState<ToursHomeScreen> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  Position? _currentPosition;
  String _selectedFilterValue = 'Nearby';

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

  Future _buildSearchResultsScreen(
    BuildContext context,
    List<Tour> filteredTours,
    String searchQuery,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Search Results for: $searchQuery',
                style: TextStyle(
                  fontFamily: poppinsFont.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: ListView.builder(
              itemCount: filteredTours.length,
              itemBuilder: (BuildContext context, int index) {
                final tour = filteredTours[index];
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tourDataAsyncUnfiltered = ref.watch(
        toursStreamProvider); // listens for changes in the toursStreamProvider,
    // this will not re-fetch the data from the database if the data is already available

    late List<Tour> tourDataUnfiltered;

    // TODO: We could separate the filtering logic into a separate component
    // WILL REPLACE CONDITIONAL LOGIC WITH TOUR FILTER.FILTERTOURS FUNCTION
    final tourDataFiltered = tourDataAsyncUnfiltered.when(
      data: (tours) {
        tourDataUnfiltered = tours;
        if (_selectedFilterValue == 'Nearby' && _currentPosition != null) {
          final closestTours = LocationFinder.findClosestToursToPosition(
            tours,
            _currentPosition!,
            8,
          );
          return closestTours;
        } else if (_selectedFilterValue == 'Highest Rated') {
          print("Highest Rated");
          List<Tour> highRatedTours = TourFilter.sortByRating(tours);
          return highRatedTours;
        } else if (_selectedFilterValue == 'Matched') {
          // final matchedTours = TourFilter.filterByActivities(, tours);
          // return matchedTours;
          return <Tour>[];
        } else if (_selectedFilterValue == 'Starting Soon') {
          List<Tour> startingSoonTours = TourFilter.filterByStartingSoon(tours);
          return startingSoonTours;
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
          print(jsonDataMap);

          final username = jsonDataMap['username'];
          final imageUrl = jsonDataMap['imageUrl'];
          final List<myNoti.Notification> notifications =
              List<myNoti.Notification>.from(jsonDataMap['notifications'].map(
                  (data) => myNoti.Notification.fromMap(
                      Map<String, dynamic>.from(data))));

          print("Notifications: $notifications");
          // filter notifications that are unread
          final unreadNotifications = notifications
              .where((notification) => !notification.isRead)
              .toList();

          final searchScreenController = TextEditingController();
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
                          child: CustomNotificationIcon(
                            notifications: notifications,
                            unreadCount: unreadNotifications.length,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) {
                                  return NotificationsScreen(
                                    notifications: notifications,
                                  );
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
                            controller: searchScreenController,
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
                          child: const Icon(Icons.search),
                          onTap: () {
                            // Search for tours based on the search bar input
                            final filteredTours = TourFilter.filterSearchBar(
                              searchScreenController.text,
                              tourDataUnfiltered,
                            );
                            // navigate to a new page with the filtered tours
                            _buildSearchResultsScreen(
                              context,
                              filteredTours,
                              searchScreenController.text,
                            );
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
                                currentLocation: true,
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
                                  // Display the dialog with the tour details
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return TourDetailsDialog(
                                          selectedTour: selectedTour);
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: TourFilterDropdown(
                      onValueChanged: (value) {
                        setState(() {
                          _selectedFilterValue = value;
                        });
                      },
                    ),
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
