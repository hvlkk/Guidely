// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/blocs/main/tours_bloc.dart' as toursBloc;
import 'package:guidely/blocs/main/tours_bloc.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/providers/tours_provider.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:guidely/screens/util/review_creator/review_creator_screen.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

  @override
  _ToursScreenState createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  final TourBloc _tourBloc = toursBloc.TourBloc();
  late User _userData;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tourBloc.dispose();
  }

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
            _userData = userData;

            if (userData.isTourGuide) {
              return [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TourCreatorScreen(),
                      ),
                    );
                  },
                ),
              ];
            }
            return null;
          },
          orElse: () {
            return null;
          },
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
          return tourDataAsync.when(
            data: (tours) {
              _tourBloc.loadTours(userData, tours);
              return StreamBuilder<toursBloc.TourState>(
                stream: _tourBloc.state,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.connectionState ==
                      ConnectionState.active) {
                    final state = snapshot.data;
                    if (state is toursBloc.ToursLoaded) {
                      return DefaultTabController(
                        length: 3,
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
                              _buildTourList(
                                  state.pastTours, _buildPastActions),
                              _buildTourList(
                                  state.liveTours, _buildLiveActions),
                              _buildTourList(
                                  state.upcomingTours, _buildUpcomingActions),
                            ],
                          ),
                        ),
                      );
                    } else if (state is toursBloc.TourError) {
                      return Center(child: Text('Error: ${state.error}'));
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text('Error: $error'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourList(List<Tour> tours, actionBuilder) {
    return tours.isEmpty
        ? Center(
            child: Text(
              'No tours available',
              style: poppinsFont.copyWith(fontSize: 15),
            ),
          )
        : ListView.builder(
            itemCount: tours.length,
            itemBuilder: (BuildContext context, int index) {
              final tour = tours[index];
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    TourListItem(tour: tour),
                    Row(
                      children: actionBuilder(tour),
                    ),
                  ],
                ),
              );
            },
          );
  }

  List<Widget> _buildUpcomingActions(Tour tour) {
    return [
      if (_userData.isTourGuide)
        OutlinedButton(
          onPressed: () {
            // Action for announcing the tour
          },
          child: const Text('Announce'),
        ),
      OutlinedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TourDetailsScreen(tour: tour),
            ),
          );
        },
        child: const Text('Get Info'),
      ),
      TextButton(
        onPressed: () {
          _tourBloc.cancelTour(tour, context);
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
        ),
        child: const Text('Cancel'),
      ),
    ];
  }

  List<Widget> _buildLiveActions(Tour tour) {
    return [
      OutlinedButton(
        onPressed: () {
          // Action for joining the tour now
        },
        child: const Text('Join Now'),
      ),
      OutlinedButton(
        onPressed: () {
          // Action for getting directions
        },
        child: const Text('Get Directions'),
      ),
    ];
  }

  List<Widget> _buildPastActions(Tour tour) {
    bool userHasReviewed =
        tour.reviews.any((review) => review.uid == _userData.uid);

    return [
      ElevatedButton(
        onPressed: userHasReviewed
            ? () {} // No action when user has reviewed
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ReviewCreatorScreen(
                        tour: tour,
                        userData: _userData,
                      );
                    },
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: userHasReviewed ? Colors.green : Colors.grey,
        ),
        child: Text(
          userHasReviewed ? 'Reviewed' : 'Review',
          style: TextStyle(
            color: userHasReviewed ? Colors.white : Colors.black,
          ),
        ),
      ),
    ];
  }
}
