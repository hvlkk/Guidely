import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item_template.dart';

class TourListItemUpcoming extends StatelessWidget {
  TourListItemUpcoming({
    super.key,
    required this.tour,
    required this.onGetDetails,
    required this.onCancel,
  });

  final Tour tour;

  void Function()? onGetDetails;
  void Function()? onCancel;

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
                onPressed: () => onGetDetails?.call(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text('Get info'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => onCancel?.call(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.red,
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color.fromARGB(255, 252, 252, 252)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
