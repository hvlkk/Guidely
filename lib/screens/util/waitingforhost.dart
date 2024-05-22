import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/screens/main/tour_session.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:guidely/services/tour_service.dart';

// TODO: Maybe we could chance the name of this screen to better reflect its purpose
// since it also has a some business logic in it
class WaitingForHostScreen extends StatelessWidget {
  const WaitingForHostScreen({super.key, required this.tour});

  final Tour tour;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          // listens to see if the tour session has started
          stream: TourService.getTourStream(tour.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.data!.exists) {
              var tourData = snapshot.data!.data() as Map<String, dynamic>;
              bool isLive = tourData['state'] == 'live';

              if (isLive) {
                // If tour session is live, navigate to TourSessionScreen
                return TourSessionScreen(tour: tour);
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
                        'here',
                        style:
                            TextStyle(fontSize: 20, color: MainColors.accent),
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
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
