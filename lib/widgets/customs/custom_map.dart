import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/models/data/waypoint.dart';

class CustomMap extends StatelessWidget {
  final List<Waypoint> waypoints;
  final bool withTrail;

  const CustomMap({
    super.key,
    required this.waypoints,
    required this.onTapWaypoint,
    this.withTrail = false,
  });

  final void Function(LatLng p0) onTapWaypoint;

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
            markers: withTrail
                ? _buildColorfulMarkers()
                : _buildOneColorMarkers(
                    BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
            polylines: withTrail ? _buildPolylines(polylineCoordinates) : {},
            onMapCreated: (GoogleMapController controller) {
              // Controller is ready
            },
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onTap: (LatLng latLng) {
              // Handle taps
              onTapWaypoint(latLng);
            },
          ),
        ),
        if (withTrail)
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

  Set<Marker> _buildColorfulMarkers() {
    return {
      for (var i = 0; i < waypoints.length; i++)
        Marker(
          markerId: MarkerId(waypoints[i].address),
          position: LatLng(waypoints[i].latitude, waypoints[i].longitude),
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
    };
  }

  Set<Marker> _buildOneColorMarkers(BitmapDescriptor descriptor) {
    return {
      for (var waypoint in waypoints)
        Marker(
          markerId: MarkerId(waypoint.address),
          position: LatLng(waypoint.latitude, waypoint.longitude),
          icon: descriptor,
          onTap: () {
            onTapWaypoint(LatLng(waypoint.latitude, waypoint.longitude));
          },
        ),
    };
  }

  Set<Polyline> _buildPolylines(List<LatLng> polylineCoordinates) {
    return {
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
    };
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
