// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:guidely/location_service.dart';
// import 'package:guidely/models/entities/tour.dart';
// import 'package:guidely/providers/tours_provider.dart';

// final closestToursProvider = Provider.autoDispose<List<Tour>>((ref) {
//   // Get the user's current position
//   Position? userPosition = LocationService.getLocation() as Position?;

//   // Get all tours
//   final allToursAsync = ref.watch(toursStreamProvider);

//   // Return a list of the 3 tours that are closest to the user's position
//   if (userPosition != null) {
//      final List<Tour> allTours = allToursAsync.data?.value ?? [];

//     final startingLocations = allTours.map((tour) => tour.tourDetails.waypoints![0]).toList();

//     // Find the closest waypoints to the user's position
//     final closestWaypoints = LocationService.findClosestWaypointsToPosition(
//       startingLocations,
//       userPosition,
//       3, // Get the 3 closest waypoints
//     );

//     // Filter tours based on the closest waypoints
//     final closestTours = allTours.where((tour) =>
//         tour.waypoints.any((waypoint) => closestWaypoints.contains(waypoint)));

//     // Convert the filtered tours to a list
//     return closestTours.toList();
//   } else {
//     return []; // Return an empty list if user's position is null
//   }
// });

