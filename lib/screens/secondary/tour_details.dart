import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/blocs/secondary/tour_details_bloc.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/screens/secondary/user_profile.dart';
import 'package:guidely/widgets/customs/custom_map.dart';
import 'package:guidely/widgets/entities/review_list_item.dart';

class TourDetailsScreen extends ConsumerStatefulWidget {
  const TourDetailsScreen({
    super.key,
    required this.tour,
  });

  final Tour tour;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TourDetailsScreenState();
  }
}

class _TourDetailsScreenState extends ConsumerState<TourDetailsScreen> {
  int currentIndex = 0;
  bool showFullDescription = false;
  late TourDetailsBloc _bloc;

  Tour get tour => widget.tour;

  @override
  void initState() {
    super.initState();
    _bloc = TourDetailsBloc(ref, tour);
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  void _uploadBooking(BuildContext context) {
    _bloc.uploadBooking(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _bloc.checkIfBooked();

    String truncatedDescription = tour.tourDetails.description.length > 250
        ? '${tour.tourDetails.description.substring(0, 250)}...'
        : tour.tourDetails.description;

    bool hasReviews = tour.reviews.isNotEmpty;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.network(
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
                        tour.tourDetails.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 20),
                      Text(tour.country, style: const TextStyle(fontSize: 16)),
                      const Spacer(),
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
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          Text(tour.location),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.timer),
                          Text(
                              '${tour.tourDetails.duration.hour} h ${tour.tourDetails.duration.minute} min'),
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
                        return UserProfileScreen(user: tour.organizer);
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
                          backgroundImage:
                              NetworkImage(tour.organizer.imageUrl),
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
                          ? tour.tourDetails.description
                          : truncatedDescription,
                    ),
                  ),
                  if (!showFullDescription &&
                      tour.tourDetails.description.length > 250)
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
              _bloc.isBooked
                  ? ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 12, 168, 59),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text(
                        'Booked',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: tour.tourDetails.startDate,
                          firstDate: tour.tourDetails.startDate,
                          lastDate: tour.tourDetails.startDate,
                        );
                        _uploadBooking(context);
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
                        'Book Now',
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
                        tour.tourDetails.waypoints![0].area,
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
                child: SizedBox(
                  height: 300,
                  child: CustomMap(
                    waypoints: tour.tourDetails.waypoints!,
                    withTrail: true,
                    onTapWaypoint: (latLng) {},
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // add the activities here
              const Text(
                'Activities',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // use a listview to display the activities
              Center(
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: tour.tourDetails.activities.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 10),
                            Text(
                              tour.tourDetails.activities[index].name,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // add the reviews here
              // use a listview to display the reviews
              Center(
                child: hasReviews
                    ? SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: tour.reviews.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child:
                                  ReviewListItem(review: tour.reviews[index]),
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No reviews yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// StreamBuilder<List<Review>>(
//   stream: _bloc.reviewsStream,
//   builder: (context, snapshot) {
//     if (snapshot.hasData) {
//       return SizedBox(
//         height: 300,
//         child: ListView.builder(
//           itemCount: snapshot.data!.length,
//           itemBuilder: (context, index) {
//             return Padding(
//               padding: const EdgeInsets.all(5.0),
//               child:
//                   ReviewListItem(review: snapshot.data![index]),
//             );
//           },
//         ),
//       );
//     } else if (snapshot.hasError) {
//       return Text('Error: ${snapshot.error}');
//     } else {
//       return const CircularProgressIndicator();
//     }
//   },
// ),
