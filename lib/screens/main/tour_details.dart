import 'package:flutter/material.dart';
import 'package:guidely/models/entities/tour.dart';

class TourDetailsScreen extends StatefulWidget {
  const TourDetailsScreen({
    super.key,
    required this.tour,
  });

  final Tour tour;

  @override
  State<StatefulWidget> createState() {
    return _TourDetailsScreenState();
  }
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  int currentIndex = 0;
  bool showFullDescription = false;

  Tour get tour => widget.tour;

  void _previousImage() {
    setState(() {
      currentIndex = (currentIndex - 1) % tour.images.length;
      if (currentIndex < 0) {
        currentIndex = tour.images.length - 1;
      }
    });
  }

  void _nextImage() {
    setState(() {
      currentIndex = (currentIndex + 1) % tour.images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    String truncatedDescription = tour.description.length > 250
        ? tour.description.substring(0, 250) + '...'
        : tour.description;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  tour.images[currentIndex],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                if (tour.images.length > 1) ...[
                  Positioned(
                    left: 10,
                    top: 100,
                    child: GestureDetector(
                      onTap: _previousImage,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 100,
                    child: GestureDetector(
                      onTap: _nextImage,
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(tour.title),
                    const Spacer(),
                    Text(tour.area),
                    const Spacer(),
                    for (final language in tour.languages)
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
                const SizedBox(height: 5),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        Text(tour.area),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.timer),
                        Text(
                            '${tour.duration.inHours} h ${tour.duration.inMinutes.remainder(60)} min'),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(
                        tour.rating.toInt(),
                        (index) => const Icon(Icons.star, color: Colors.yellow),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Card(
              child: Column(
                children: [
                  Text(
                    'The Organizer is verified',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tour Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showFullDescription = !showFullDescription;
                    });
                  },
                  child: Text(
                    showFullDescription
                        ? tour.description
                        : truncatedDescription,
                  ),
                ),
                if (!showFullDescription && tour.description.length > 250)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showFullDescription = true;
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Show more',
                          style: TextStyle(color: Colors.black),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                if (showFullDescription)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showFullDescription = false;
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Show less',
                          style: TextStyle(color: Colors.black),
                        ),
                        Icon(
                          Icons.arrow_drop_up,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Open the calendar to select a date
              },
              child: const Text('Check Availabilty'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(15),
                textStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // NOT READY CODE
            const SizedBox(height: 10),
            const Text('PROOF THAT SCROLLING WORKS'),
            const SizedBox(height: 10),
            Text(tour.description),
            // Text(tour.startLocation.toString()),
          ],
        ),
      ),
    );
  }
}
