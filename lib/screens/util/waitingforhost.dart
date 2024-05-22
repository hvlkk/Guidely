import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/screens/main/tour_session.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:guidely/blocs/main/tours_bloc.dart';

class WaitingForHostScreen extends StatelessWidget {
  const WaitingForHostScreen({super.key, required this.tour});

  final Tour tour;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting...')),
      body: Center(
        child: StreamBuilder<TourSessionState>(
          stream: TourBloc().sessionState,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data!.isLive) {
              // If tour session is live, navigate to TourSessionScreen
              return const TourSessionScreen();
            } else {
              // If tour session has not started yet, show waiting message
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'While waiting, you can see the tour details ',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  GestureDetector(
                    child: const Text(
                      'here', // Word you want to make clickable
                      style: TextStyle(
                          fontSize: 20,
                          color: MainColors
                              .accent), // Add a color to indicate it's clickable
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TourDetailsScreen(tour: tour),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
