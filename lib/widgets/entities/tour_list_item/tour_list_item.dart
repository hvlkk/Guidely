import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item_template.dart';

class TourListItem extends StatelessWidget {
  const TourListItem({
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
          Text(
            tour.tourDetails.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            tour.location ?? 'Unknown area',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
