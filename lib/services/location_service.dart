import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<Position> getLocation() async {
    // Check if location permission is granted
    var permissionStatus = await Permission.location.status;

    if (permissionStatus.isGranted) {
      try {
        // Location permission is granted, get the current location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        return position;
      } catch (e) {
        // Handle error while getting the location
        rethrow; // Rethrow the error for the caller to handle
      }
    } else {
      // Location permission is not granted, handle it accordingly
      // For example, show a dialog to explain why the permission is needed
      throw Exception('Location permission not granted');
    }
  }

  static Future<void> requestLocationPermission() async {
    // Check if permission is granted
    var status = await Permission.location.request();

    if (status.isDenied) {
      // Permission was denied, handle it accordingly
      // For example, show a dialog to explain why the permission is needed
    }
  }

  static List<Tour> findClosestToursToPosition(
      List<Tour> tours, Position userPosition, int k) {
    // Calculate the distance from the user's position to each starting location of the tours
    List<Map<String, dynamic>> distances = [];
    const int MAX_DISTANCE = 100; // Maximum distance in kilometers
    for (var tour in tours) {
      if (tour.tourDetails.waypoints!.isNotEmpty) {
        double distance = _calculateDistance(
            userPosition.latitude,
            userPosition.longitude,
            tour.tourDetails.waypoints![0].latitude,
            tour.tourDetails.waypoints![0].longitude);
        // set a limiter for the distance of the tours
        if (distance > MAX_DISTANCE) {
          continue;
        }
        distances.add({'tour': tour, 'distance': distance});
      }
    }

    // Sort the tours by distance
    distances.sort((a, b) => a['distance'].compareTo(b['distance']));

    // Get the k closest tours
    List<Tour> closestTours = [];
    for (var i = 0; i < min(k, distances.length); i++) {
      closestTours.add(distances[i]['tour']);
    }

    return closestTours;
  }

  // Function to calculate the distance between two points using Haversine formula
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  // Function to convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
