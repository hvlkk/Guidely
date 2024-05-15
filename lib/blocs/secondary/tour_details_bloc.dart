import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/models/entities/review.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/providers/tours_provider.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/services/user_service.dart';

class TourDetailsBloc {
  final Tour tour;
  final WidgetRef _ref;
  bool isBooked = false;
  List<Review> reviews = [];

  TourDetailsBloc(this._ref, this.tour);

  void checkIfBooked() async {
    if (isBooked) {
      return;
    }
    final user = _ref.watch(userDataProvider);
    user.when(
      data: (userData) {
        isBooked = userData.bookedTours.contains(tour.uid);
      },
      error: (Object error, StackTrace stackTrace) {},
      loading: () {},
    );
  }

  Future<void> uploadBooking(BuildContext context) async {
    final user = _ref.watch(userDataProvider);
    user.when(
      data: (userData) async {
        if (userData.organizedTours.contains(tour.uid)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You cannot book your own tour!'),
            ),
          );
        } else {
          userData.bookedTours.add(tour.uid);
          UserService.updateData(context, userData.uid, {
            'bookedTours': userData.bookedTours,
          });

          final tours = _ref.watch(toursStreamProvider);
          tours.when(
            data: (data) {
              final tourIndex =
                  data.indexWhere((element) => element.uid == tour.uid);
              data[tourIndex].registeredUsers.add(userData.uid);
              UserService.updateData(context, tour.uid, {
                'registeredUsers': data[tourIndex].registeredUsers,
              });
            },
            error: (Object error, StackTrace stackTrace) {},
            loading: () {},
          );
        }
      },
      error: (Object error, StackTrace stackTrace) {},
      loading: () {},
    );
  }
}
