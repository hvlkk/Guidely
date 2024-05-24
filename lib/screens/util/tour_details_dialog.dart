import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/screens/secondary/tour_details.dart';
import 'package:intl/intl.dart';

class TourDetailsDialog extends StatelessWidget {
  final Tour selectedTour;

  const TourDetailsDialog({super.key, required this.selectedTour});

  DateTime _convertTimeOfDayToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final dateTime = _convertTimeOfDayToDateTime(time);
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    // Convert start time and duration to DateTime
    final startTime = _convertTimeOfDayToDateTime(selectedTour.tourDetails.startTime);
    final endTime = startTime.add(Duration(
      hours: selectedTour.tourDetails.duration.hour,
      minutes: selectedTour.tourDetails.duration.minute,
    ));
    final startTimeString = _formatTimeOfDay(selectedTour.tourDetails.startTime);
    final endTimeString = DateFormat('hh:mm a').format(endTime);
    final startDateString =
        DateFormat('yyyy-MM-dd').format(selectedTour.tourDetails.startDate);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Tour Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                selectedTour.images[0],
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            // Tour Name
            Text(
              'Tour Name: ${selectedTour.tourDetails.title}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // Tour Duration
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.blue),
                const SizedBox(width: 5),
                Text(
                  'Duration: $startTimeString - $endTimeString',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Tour Start Date
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 5),
                Text(
                  'Start Date: $startDateString',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Learn More Button
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => TourDetailsScreen(
                        tour: selectedTour,
                      ),
                    ),
                  );
                },
                child: const Text('Learn more'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}