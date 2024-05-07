import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item_template.dart';

class TourListItemUpcoming extends StatelessWidget {
  const TourListItemUpcoming({
    super.key,
    required this.tour,
  });

  final Tour tour;

  @override
  Widget build(BuildContext context) {
    return TourListItemTemplate(
      tour: tour,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // this should be organizer's name
          Text(
            tour.tourDetails.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text('Get info'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
