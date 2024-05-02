import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/models/data/waypoint.dart';

class CustomTrailMap extends StatelessWidget {
  final List<Waypoint> waypoints;

  const CustomTrailMap({
    super.key,
    required this.waypoints,
  });

  @override
  Widget build(BuildContext context) {
    List<LatLng> polylineCoordinates = [];
    for (final waypoint in waypoints) {
      polylineCoordinates.add(LatLng(waypoint.latitude, waypoint.longitude));
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(waypoints[0].latitude, waypoints[0].longitude),
        zoom: 13.5,
      ),
      markers: {
        for (final waypoint in waypoints)
          Marker(
            markerId: MarkerId(waypoint.address),
            position: LatLng(waypoint.latitude, waypoint.longitude),
            infoWindow: InfoWindow(
              title: waypoint.address,
            ),
          ),
      },
      polylines: {
        Polyline(
          polylineId: const PolylineId('trail'),
          color: Colors.black,
          points: polylineCoordinates,
          width: 2,
          patterns: [
            PatternItem.dash(10),
            PatternItem.gap(5),
          ],
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        // Controller is ready
      },
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
    );
  }
}
