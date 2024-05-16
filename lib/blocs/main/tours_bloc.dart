import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/services/user_service.dart';
import 'package:guidely/utils/tour_filter.dart';

abstract class TourState {}

class ToursLoading extends TourState {}

class ToursLoaded extends TourState {
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

class TourBloc {
  User? userData;
  List<Tour>? tours;

  final _stateController = StreamController<TourState>();
  Stream<TourState> get state => _stateController.stream;

  void loadTours(User user, List<Tour> tours) {
    userData = user;
    this.tours = tours;
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
