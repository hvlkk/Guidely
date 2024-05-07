import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';

class TourListItemTemplate extends StatelessWidget {
  const TourListItemTemplate({
    super.key,
    required this.tour,
    required this.child,
  });

  final Tour tour;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/tours/tour2.jpg', // this should be tour's image uploaded or received by an api
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Row(
                  children: [
                    for (final language in tour.tourDetails.languages)
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12.5,
                            backgroundImage: AssetImage(
                              'icons/flags/png250px/${language.code}.png',
                              package: 'country_icons',
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                  radius: 25,
                  // this should be organizer's photo profile
                  backgroundImage: NetworkImage(tour.organizer.imageUrl)),
              const SizedBox(width: 10),
              child
            ],
          )
        ],
      ),
    );
  }
}
