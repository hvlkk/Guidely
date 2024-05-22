import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/widgets/entities/tour_list_item/tour_list_item_template.dart';

class TourListItem extends StatelessWidget {
  const TourListItem({
    super.key,
    required this.tour,
    this.displayRemainingTime = false,
  });

  final Tour tour;
  final bool displayRemainingTime;

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
          if (displayRemainingTime)
            Text(
              _getRemainingTimeText(
                  tour.tourDetails.startTime, tour.tourDetails.startDate),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  String _getRemainingTimeText(TimeOfDay startTime, DateTime startDate) {
    final now = DateTime.now();

    DateTime startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    // If the start time is earlier in the day than the current time, consider it the next day
    if (startDateTime.isBefore(now)) {
      startDateTime = startDateTime.add(const Duration(days: 1));
    }

    final differenceInMinutes = startDateTime.difference(now).inMinutes;

    if (differenceInMinutes > 0) {
      if (differenceInMinutes >= 60) {
        final hours = differenceInMinutes ~/ 60;
        final minutes = differenceInMinutes % 60;
        return 'Starts in $hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes > 1 ? 's' : ''}';
      } else {
        return 'Starts in $differenceInMinutes minute${differenceInMinutes > 1 ? 's' : ''}';
      }
    } else {
      return 'Tour has started';
    }
  }
}
