import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/services/business_layer/session_service.dart';
import 'package:guidely/services/business_layer/tour_service.dart';
import 'package:guidely/services/business_layer/user_service.dart';

class TourSessionState {
  final bool isLive;

  TourSessionState({required this.isLive});
}

class TourBloc {
  User? userData;
  List<Tour>? tours;

  void startTour(Tour tour) async {
    String id = await SessionService.createSession(tour);
    TourService.updateTourData(tour.uid, {'hasStarted': true, 'sessionId': id});
  }

  Future<void> cancelTour(Tour tour, String uid, BuildContext context) async {
    await UserService.updateData(
      context,
      uid,
      {
        'bookedTours': FieldValue.arrayRemove([tour.uid]),
        'organizedTours': FieldValue.arrayRemove([tour.uid]),
      },
    );
    await TourService.deleteTour(tour.uid);
  }

  void announceTour(Tour tour, String text) {
    TourService.updateTourData(tour.uid, {'recentAnnouncement': text});
  }
}
