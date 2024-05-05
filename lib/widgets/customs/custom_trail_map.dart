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

    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(waypoints[0].latitude, waypoints[0].longitude),
              zoom: 13.5,
            ),
            markers: {
              for (var i = 0; i < waypoints.length; i++)
                Marker(
                  markerId: MarkerId(waypoints[i].address),
                  position:
                      LatLng(waypoints[i].latitude, waypoints[i].longitude),
                  infoWindow: InfoWindow(
                    title: waypoints[i].address,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    i == 0
                        ? BitmapDescriptor.hueGreen // First waypoint
                        : i == waypoints.length - 1
                            ? BitmapDescriptor.hueRed // Last waypoint
                            : BitmapDescriptor.hueCyan, // Middle waypoints
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
          ),
        ),
        SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem("Meeting location", Colors.green),
              _buildLegendItem("Last to be visited location", Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
