import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/firestore_service.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/providers/tours_provider.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item_upcoming.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

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
      ),
      body: userDataAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (userData) {
          final isTourGuide = userData.isTourGuide;
          List<Tour> tourDataFiltered = tourDataAsync.when(
            data: (tours) {
              Set<Tour> res = Set<Tour>();
              for (final tour in tours) {
                if (!userData.bookedTours.contains(tour.uid) &&
                    !userData.organizedTours.contains(tour.uid)) {
                  continue;
                }
                res.add(tour);
              }
              return res.toList();
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
              // TODO: to be removed later
              body: TabBarView(
                children: [
                  isTourGuide
                      ? _buildTourGuideContent()
                      : _buildUpcoming(tourDataFiltered, userData),
                  isTourGuide
                      ? _buildTourGuideContent()
                      : _buildUpcoming(tourDataFiltered, userData),
                  _buildUpcoming(tourDataFiltered, userData),
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
                    FirestoreService.updateUserData(
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

  Widget _buildTourGuideContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nothing to see here, why don\'t you add a tour?',
            style: poppinsFont.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // navigate to the add tour screen
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const TourCreatorScreen();
              }));
              setState(() {});
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(ButtonColors.primary),
            ),
            child: Text(
              'Add a tour',
              style: poppinsFont.copyWith(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
