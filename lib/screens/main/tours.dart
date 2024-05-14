import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/providers/tours_provider.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator.dart';
import 'package:guidely/utils/tour_filter.dart';
import 'package:guidely/services/tour_service.dart';
import 'package:guidely/services/user_service.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item_upcoming.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({Key? key});

  @override
  _ToursScreenState createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  final List<String> tabNames = ['Past tours', 'Live tours', 'Upcoming tours'];

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(userDataProvider);
    final tourDataAsync = ref.watch(toursStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tours',
          style: poppinsFont.copyWith(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: userDataAsync.maybeWhen(
          data: (userData) {
            if (userData.isTourGuide) {
              return [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // navigate to the add tour screen
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const TourCreatorScreen();
                    }));
                    setState(() {});
                  },
                ),
              ];
            }
            return null;
          },
          orElse: () => [],
        ),
      ),
      body: userDataAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (userData) {
          List<Tour> upcomingTours = [];
          List<Tour> pastTours = [];
          List<Tour> liveTours = [];
          tourDataAsync.when(
            data: (tours) {
              List<Tour> res = [];
              // filters the tours that are either booked or organized by this user
              for (final tour in tours) {
                if (!userData.bookedTours.contains(tour.uid) &&
                    !userData.organizedTours.contains(tour.uid)) {
                  continue;
                }
                res.add(tour);
              }
              upcomingTours = TourFilter.filterTourType(
                TourType.upcoming,
                res,
              );
              pastTours = TourFilter.filterTourType(
                TourType.past,
                res,
              );
              liveTours = TourFilter.filterTourType(
                TourType.live,
                res,
              );
            },
            loading: () => [],
            error: (error, stackTrace) => [],
          );
          return DefaultTabController(
            length: tabNames.length,
            child: Scaffold(
              appBar: const TabBar(
                tabs: [
                  Tab(text: 'Past'),
                  Tab(text: 'Live now'),
                  Tab(text: 'Upcoming'),
                ],
              ),
              body: TabBarView(
                children: [
                  _buildPast(pastTours, userData),
                  _buildLive(liveTours, userData),
                  _buildUpcoming(upcomingTours, userData),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcoming(List<Tour> tourDataFiltered, User userData) {
    return tourDataFiltered.isEmpty
        ? Center(
            child: Text('No upcoming tours',
                style: poppinsFont.copyWith(fontSize: 15)))
        : ListView.builder(
            itemCount: tourDataFiltered.length,
            itemBuilder: (BuildContext context, int index) {
              final tour = tourDataFiltered[index];
              final isAHostedTour = userData.organizedTours.contains(tour.uid);
              return Padding(
                padding: const EdgeInsets.all(8),
                child: TourListItemUpcoming(
                  tour: tour,
                  onGetDetails: () {
                    // navigate to the tour details screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return TourDetailsScreen(tour: tour);
                        },
                      ),
                    );
                  },
                  onCancel: () async {
                    // cancel the tour
                    userData.bookedTours.remove(tour.uid);
                    isAHostedTour
                        ? userData.organizedTours.remove(tour.uid)
                        : null;
                    // update the user data in the database
                    TourService.updateTourData(
                      context,
                      userData.uid,
                      {
                        'bookedTours': userData.bookedTours,
                        'organizedTours': userData.organizedTours,
                      },
                    );
                    // force a rebuild of the widget
                    setState(() {});
                  },
                  isHostedTour: isAHostedTour,
                ),
              );
            },
          );
  }

  Widget _buildLive(List<Tour> tourDataFiltered, User userData) {
    return tourDataFiltered.isEmpty
        ? Center(
            child: Text('No live tours',
                style: poppinsFont.copyWith(fontSize: 15)))
        : ListView.builder(
            itemCount: tourDataFiltered.length,
            itemBuilder: (BuildContext context, int index) {
              final tour = tourDataFiltered[index];
              final isAHostedTour = userData.organizedTours.contains(tour.uid);
              return Padding(
                padding: const EdgeInsets.all(8),
                child: TourListItemUpcoming(
                  tour: tour,
                  onGetDetails: () {
                    // navigate to the tour details screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return TourDetailsScreen(tour: tour);
                        },
                      ),
                    );
                  },
                  onCancel: () async {
                    // cancel the tour
                    userData.bookedTours.remove(tour.uid);
                    isAHostedTour
                        ? userData.organizedTours.remove(tour.uid)
                        : null;
                    // update the user data in the database
                    TourService.updateTourData(
                      context,
                      userData.uid,
                      {
                        'bookedTours': userData.bookedTours,
                        'organizedTours': userData.organizedTours,
                      },
                    );
                    // force a rebuild of the widget
                    setState(() {});
                  },
                  isHostedTour: isAHostedTour,
                ),
              );
            },
          );
  }

  Widget _buildPast(List<Tour> tourDataFiltered, User userData) {
    return tourDataFiltered.isEmpty
        ? Center(
            child: Text('No past tours',
                style: poppinsFont.copyWith(fontSize: 15)))
        : ListView.builder(
            itemCount: tourDataFiltered.length,
            itemBuilder: (BuildContext context, int index) {
              final tour = tourDataFiltered[index];
              final isAHostedTour = userData.organizedTours.contains(tour.uid);
              return Padding(
                padding: const EdgeInsets.all(8),
                child: TourListItemUpcoming(
                  tour: tour,
                  onGetDetails: () {
                    // navigate to the tour details screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return TourDetailsScreen(tour: tour);
                        },
                      ),
                    );
                  },
                  onCancel: () async {
                    // cancel the tour
                    userData.bookedTours.remove(tour.uid);
                    isAHostedTour
                        ? userData.organizedTours.remove(tour.uid)
                        : null;
                    // update the user data in the database
                    UserService.updateData(
                      context,
                      userData.uid,
                      {
                        'bookedTours': userData.bookedTours,
                        'organizedTours': userData.organizedTours,
                      },
                    );
                    // force a rebuild of the widget
                    setState(() {});
                  },
                  isHostedTour: isAHostedTour,
                ),
              );
            },
          );
  }
}
