import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/services/tour_service.dart';
import 'package:guidely/services/user_service.dart';
import 'package:guidely/utils/tour_filter.dart';

abstract class TourState {}

abstract class TourLoadingState extends TourState {}

class ToursLoading extends TourLoadingState {}

class ToursLoaded extends TourLoadingState {
  final List<Tour> upcomingTours;
  final List<Tour> pastTours;
  final List<Tour> liveTours;

  ToursLoaded(
      {required this.upcomingTours,
      required this.pastTours,
      required this.liveTours});
}

class TourError extends TourState {
  final String error;

  TourError({required this.error});
}

class TourSessionState extends TourState {
  final bool isLive;

  TourSessionState({required this.isLive});
}

class TourBloc {
  User? userData;
  List<Tour>? tours;

  final _stateController = StreamController<TourState>();
  Stream<TourState> get state => _stateController.stream;

  void loadTours(User user, List<Tour> tours) {
    this.tours = tours;
    userData = user;
    _loadTours();
  }

  void _loadTours() {
    try {
      List<Tour> userTours = tours!
          .where((tour) =>
              userData!.bookedTours.contains(tour.uid) ||
              userData!.organizedTours.contains(tour.uid))
          .toList();

      List<Tour> upcomingTours =
          TourFilter.filterTourType(TourType.upcoming, userTours);
      List<Tour> pastTours =
          TourFilter.filterTourType(TourType.past, userTours);
      List<Tour> liveTours =
          TourFilter.filterTourType(TourType.live, userTours);

      _stateController.add(
        ToursLoaded(
          upcomingTours: upcomingTours,
          pastTours: pastTours,
          liveTours: liveTours,
        ),
      );
    } catch (e) {
      _stateController.add(TourError(error: e.toString()));
    }
  }

  void startTour(Tour tour) {
    TourService.updateTourData(tour.uid, {'state': 'live'});
  }

  Future<void> cancelTour(Tour tour, BuildContext context) async {
    if (userData == null) return;
    final isAHostedTour = userData!.organizedTours.contains(tour.uid);
    userData!.bookedTours.remove(tour.uid);
    if (isAHostedTour) {
      userData!.organizedTours.remove(tour.uid);
    }
    await UserService.updateData(
      context,
      userData!.uid,
      {
        'bookedTours': userData!.bookedTours,
        'organizedTours': userData!.organizedTours,
      },
    );
    _loadTours(); // Reload tours after cancelling
  }

  void dispose() {
    _stateController.close();
  }
}
