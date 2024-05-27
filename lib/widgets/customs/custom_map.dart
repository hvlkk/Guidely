import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/models/data/waypoint.dart';
import 'package:guidely/utils/location_finder.dart';

class CustomMap extends StatelessWidget {
  final List<Waypoint> waypoints;
  final bool withTrail;
  final bool currentLocation;
  final bool onTourSession;

  const CustomMap({
    super.key,
    required this.waypoints,
    required this.onTapWaypoint,
    this.withTrail = false,
    this.currentLocation = false,
    this.onTourSession = false,
  });

  final void Function(LatLng p0) onTapWaypoint;

  @override
  Widget build(BuildContext context) {
    List<LatLng> polylineCoordinates = [];
    for (final waypoint in waypoints) {
      polylineCoordinates.add(LatLng(waypoint.latitude, waypoint.longitude));
    }

    // TODO: Implement custom marker icon
    //   BitmapDescriptor organizerIcon = BitmapDescriptor.defaultMarker;

    //   Future<Uint8List> _getBytesFromNetworkImage(String url) async {
    //   final http.Response response = await http.get(Uri.parse(url));
    //   final Uint8List bytes = response.bodyBytes;
    //   final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 100);
    //   final ui.FrameInfo frame = await codec.getNextFrame();
    //   final ByteData? byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    //   return byteData!.buffer.asUint8List();
    // }

    //   Future<void> _setCustomMarkerIcon() async {
    //   final Uint8List markerIcon = await _getBytesFromNetworkImage();
    //     organizerIcon = BitmapDescriptor.fromBytes(markerIcon);
    // }

    return Column(
      children: [
        Expanded(
          child: FutureBuilder<LatLng?>(
            future: currentLocation
                ? LocationFinder.getLocation().then(
                    (position) => LatLng(position.latitude, position.longitude))
                : Future.value(null),
            builder: (context, snapshot) {
              LatLng? userLocation = snapshot.data;
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(waypoints[0].latitude, waypoints[0].longitude),
                  zoom: 13.5,
                ),
                markers: {
                  ...withTrail
                      ? _buildColorfulMarkers()
                      : _buildOneColorMarkers(
                          BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed),
                        ),
                  if (userLocation != null)
                    _buildCustomMarker(
                      "currentLocation",
                      userLocation,
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                      "Your Location",
                    ),
                  // TEMPORARY: For testing purposes
                  if (onTourSession) ...{
                    _buildCustomMarker(
                      "organizerLiveLocation",
                      LatLng(waypoints[0].latitude, waypoints[0].longitude),
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      "Guide's Location",
                    ),
                    _buildCustomMarker(
                      "tourStartingPoint",
                      LatLng(waypoints[1].latitude,
                          waypoints[1].longitude),
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      "Tour Starting Point",
                    ),
                    _buildCustomMarker(
                      "tourEndingPoint",
                      LatLng(waypoints[waypoints.length - 1].latitude,
                          waypoints[waypoints.length - 1].longitude),
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                      "Tour Ending Point",
                    ),
                  }
                },
                polylines:
                    withTrail ? _buildPolylines(polylineCoordinates) : {},
                onMapCreated: (GoogleMapController controller) {
                  // Controller is ready
                },
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                onTap: (LatLng latLng) {
                  // Handle taps
                  onTapWaypoint(latLng);
                },
              );
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

  Marker _buildCustomMarker(
    String markerId,
    LatLng position,
    BitmapDescriptor icon,
    String title,
  ) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: icon,
      infoWindow: InfoWindow(title: title),
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
