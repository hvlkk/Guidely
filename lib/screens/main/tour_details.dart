import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/review.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/screens/main/host_profile.dart';
import 'package:guidely/widgets/entities/review_list_item.dart';

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
        ? '${tour.description.substring(0, 250)}...'
        : tour.description;

    // TEMP CODE FOR DEBUGGING
    List<Review> reviews = [];

    Review review1 = Review(
      grade: 5,
      comment: 'Great tour!',
      date: DateTime.now(),
      user: User(
        uid: '1',
        username: 'John Doe',
        email: 'ippo@example.com',
        imageUrl: 'assets/images/user.png',
      ),
    );

    Review review2 = Review(
      grade: 4,
      comment: 'Nice tour!',
      date: DateTime.now(),
      user: User(
        uid: '2',
        username: 'Jane Doe',
        email: 'jane@example',
        imageUrl: 'assets/images/user.png',
      ),
    );

    reviews.add(review1);
    reviews.add(review2);
    // END TEMP CODE

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
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
                      Text(
                        tour.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
                          (index) =>
                              const Icon(Icons.star, color: Colors.yellow),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) {
                        return HostProfileScreen(user: tour.organizer);
                      },
                    ),
                  );
                },
                child: Card(
                  color: const Color.fromARGB(239, 255, 255, 255),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(tour.organizer.imageUrl),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Organized by: ${tour.organizer.username}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Verified Guide',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Open the calendar to select a date
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ButtonColors.attention,
                  padding: const EdgeInsets.all(15),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 26, 23, 23),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  'Check Availabilty',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Roadmap',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.flag, color: Colors.red),
                  Column(
                    children: [
                      const Text(
                        'Meeting Point',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tour.startLocation.address,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 300, // Adjust the height as needed
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          tour.startLocation.latitude,
                          tour.startLocation
                              .longitude), // Initial position (San Francisco)
                      zoom: 12, // Zoom level
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('marker_1'),
                        position: LatLng(tour.startLocation.latitude,
                            tour.startLocation.longitude), // Marker position
                        infoWindow: const InfoWindow(
                            title: 'Athens Center'), // Info window
                      ),
                    },
                    onMapCreated: (GoogleMapController controller) {
                      // Controller is ready
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ReviewListItem(review: reviews[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
