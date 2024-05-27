// // Map Section
// import 'package:flutter/material.dart';
// import 'package:guidely/models/entities/tour.dart';
// import 'package:guidely/widgets/customs/custom_map.dart';

// class MapSection extends StatelessWidget {
//   const MapSection({super.key, required this.tour});

//   final Tour tour;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: SizedBox(
//             height: 170,
//             child: CustomMap(
//               waypoints: [tour.tourDetails.waypoints![0]],
//               withTrail: false,
//               onTourSession: true,
//               onTapWaypoint: (latLng) {},
//             ),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Guide\'s Current Location',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             IconButton(
//               icon: const Icon(
//                 Icons.location_on,
//                 size: 24,
//                 color: Colors.red,
//               ),
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guidely/models/data/waypoint.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/widgets/customs/custom_map.dart';

class MapSection extends StatefulWidget {
  const MapSection({super.key, required this.tour});

  final Tour tour;

  @override
  _MapSectionState createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<DocumentSnapshot>? _locationStream;

  @override
  void initState() {
    super.initState();
    // Initialize the location stream for the tour guide
    _locationStream = _firestore
        .collection('locations')
        .doc(widget.tour.organizer.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 170,
            child: StreamBuilder<DocumentSnapshot>(
              stream: _locationStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var locationData =
                    snapshot.data?.data() as Map<String, dynamic>?;
                if (locationData == null) {
                  return const Center(child: Text('No location data available'));
                }

                double latitude = locationData['latitude'];
                double longitude = locationData['longitude'];

                return CustomMap(
                  waypoints: [
                    // Guide's current location
                    Waypoint(
                      address: '',
                      latitude: latitude,
                      longitude: longitude,
                    ),
                    // Starting location
                    widget.tour.tourDetails.waypoints![0],
                    // Ending location
                    widget.tour.tourDetails.waypoints![widget.tour.tourDetails.waypoints!.length - 1],
                  ],
                  withTrail: false,
                  onTourSession: true,
                  onTapWaypoint: (latLng) {},
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Guide\'s Current Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.location_on,
                  size: 22,
                  color: Colors.red,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
