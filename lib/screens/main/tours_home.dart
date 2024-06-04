import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/blocs/main/tours_home_bloc.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/notification.dart' as my_noti;
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/providers/tours_provider.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:guidely/screens/util/notifications.dart';
import 'package:guidely/screens/util/tour_details_dialog.dart';
import 'package:guidely/screens/util/tour_filter_dropdown.dart';
import 'package:guidely/widgets/customs/custom_map.dart';
import 'package:guidely/widgets/customs/custom_notification_icon.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item.dart';

class ToursHomeScreen extends ConsumerStatefulWidget {
  const ToursHomeScreen({super.key});

  @override
  _ToursHomeScreenState createState() => _ToursHomeScreenState();
}

class _ToursHomeScreenState extends ConsumerState<ToursHomeScreen> {
  final ToursHomeBloc _toursHomeBloc = ToursHomeBloc();
  Position? _currentPosition;
  String _selectedFilterValue = 'Nearby';
  late List<Tour> tourDataUnfiltered;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _showNoToursMessage = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    _waitIndicator(); // Start the wait indicator
  }

  Future<void> _initialize() async {
    _currentPosition = await _toursHomeBloc.getCurrentPosition();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tourDataAsyncUnfiltered = ref.watch(toursStreamProvider);
    final tourDataFiltered = tourDataAsyncUnfiltered.when<List<Tour>>(
      data: (List<Tour> tours) {
        tourDataUnfiltered = tours;
        return _toursHomeBloc.filterTours(
          tours,
          _selectedFilterValue,
          _currentPosition,
        );
      },
      loading: () => [],
      error: (error, stackTrace) => [],
    );

    final startLocations =
        tourDataFiltered.map((tour) => tour.tourDetails.waypoints![0]).toList();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _toursHomeBloc.userStream,
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
          final List<my_noti.Notification> notifications =
              List<my_noti.Notification>.from(jsonDataMap['notifications'].map(
                  (data) => my_noti.Notification.fromMap(
                      Map<String, dynamic>.from(data))));

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
                        Container(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: Text(
                            'Welcome, $username!',
                            style: TextStyle(
                              fontFamily: poppinsFont.fontFamily,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: CustomNotificationIcon(
                            notifications: notifications,
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
                            controller: _searchController,
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
                            final filteredTours =
                                _toursHomeBloc.filterSearchBar(
                              _searchController.text,
                              tourDataUnfiltered,
                            );
                            _navigateToSearchResultsScreen(
                              context,
                              filteredTours,
                              _searchController.text.trim(),
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
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : tourDataFiltered.isEmpty
                                ? _buildNoToursAvailable()
                                : CustomMap(
                                    organizerIcon: "",
                                    waypoints: startLocations,
                                    withTrail: false,
                                    currentLocation: true,
                                    onTapWaypoint: (LatLng p0) {
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
                      onChanged: (String? newValue) {},
                    ),
                  ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : tourDataFiltered.isEmpty
                          ? _buildNoToursAvailable()
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: tourDataFiltered.length,
                              itemBuilder: (BuildContext context, int index) {
                                final tour = tourDataFiltered[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TourDetailsScreen(tour: tour),
                                        ),
                                      );
                                    },
                                    child: TourListItem(tour: tour),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> _navigateToSearchResultsScreen(
      BuildContext context, List<Tour> filteredTours, String searchQuery) {
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TourDetailsScreen(tour: tour),
                        ),
                      );
                    },
                    child: TourListItem(tour: tour),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoToursAvailable() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'No tours available',
        style: TextStyle(
          fontFamily: poppinsFont.fontFamily,
          fontSize: 20,
        ),
      ),
    );
  }

  void _waitIndicator() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _showNoToursMessage = tourDataUnfiltered.isEmpty;
      });
    });
  }
}
