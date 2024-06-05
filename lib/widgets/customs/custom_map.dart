import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/models/data/waypoint.dart';
import 'package:guidely/utils/location_finder.dart';

class CustomMap extends StatefulWidget {
  final String organizerIcon;
  final List<Waypoint> waypoints;
  final bool withTrail;
  final bool currentLocation;
  final bool onTourSession;
  final void Function(LatLng p0) onTapWaypoint;

  const CustomMap({
    super.key,
    required this.organizerIcon,
    required this.waypoints,
    required this.onTapWaypoint,
    this.withTrail = false,
    this.currentLocation = false,
    this.onTourSession = false,
  });

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  LatLng? _userLocation;
  Timer? _locationTimer;

  BitmapDescriptor organizerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation) {
      _updateUserLocation();
      _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _updateUserLocation();
      });
    }
    setCustomeMarkerIcon();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(String imagePath, int width) async {
  final ByteData imageData = await rootBundle.load(imagePath);
  final ui.Codec codec = await ui.instantiateImageCodec(
    imageData.buffer.asUint8List(),
    targetWidth: width,
  );
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List resizedImageData = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(resizedImageData);
}

  void setCustomeMarkerIcon() {
    createCustomMarkerBitmap('assets/images/organizerIcon.png', 150).then((icon) {
  setState(() {
    organizerIcon = icon;
  });
});
  }

  Future<void> _updateUserLocation() async {
    final position = await LocationFinder.getLocation();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Marker _buildCustomMarker(
    String markerId,
    LatLng position,
    BitmapDescriptor icon,
    String title,
    Offset? anchor,
  ) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: icon,
      infoWindow: InfoWindow(title: title),
      anchor: anchor ?? const Offset(0.5, 1.0),
    );
  }

  Set<Marker> _buildColorfulMarkers() {
    return {
      for (var i = 0; i < widget.waypoints.length; i++)
        Marker(
          markerId: MarkerId(widget.waypoints[i].address),
          position: LatLng(
              widget.waypoints[i].latitude, widget.waypoints[i].longitude),
          infoWindow: InfoWindow(
            title: widget.waypoints[i].address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0
                ? BitmapDescriptor.hueGreen // First waypoint
                : i == widget.waypoints.length - 1
                    ? BitmapDescriptor.hueRed // Last waypoint
                    : BitmapDescriptor.hueCyan, // Middle waypoints
          ),
        ),
    };
  }

  Set<Marker> _buildOneColorMarkers(BitmapDescriptor descriptor) {
    return {
      for (var waypoint in widget.waypoints)
        Marker(
          markerId: MarkerId(waypoint.address),
          position: LatLng(waypoint.latitude, waypoint.longitude),
          icon: descriptor,
          onTap: () {
            widget.onTapWaypoint(LatLng(waypoint.latitude, waypoint.longitude));
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

  @override
  Widget build(BuildContext context) {
    List<LatLng> polylineCoordinates = [];
    for (final waypoint in widget.waypoints) {
      polylineCoordinates.add(LatLng(waypoint.latitude, waypoint.longitude));
    }

    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  widget.waypoints[0].latitude, widget.waypoints[0].longitude),
              zoom: 13.5,
            ),
            markers: {
              ...widget.withTrail
                  ? _buildColorfulMarkers()
                  : _buildOneColorMarkers(
                      BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                    ),
              if (_userLocation != null)
                _buildCustomMarker(
                  "currentLocation",
                  _userLocation!,
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                  "Your Location",
                  null,
                ),
              if (widget.onTourSession) ...{
                _buildCustomMarker(
                  "tourOrganizer",
                  LatLng(widget.waypoints[0].latitude,
                      widget.waypoints[0].longitude),
                  organizerIcon,
                  "Tour Organizer",
                  const Offset(0.5, 1.65),
                ),
                _buildCustomMarker(
                  "tourStartingPoint",
                  LatLng(widget.waypoints[1].latitude,
                      widget.waypoints[1].longitude),
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  "Tour Starting Point",
                  null,
                ),
                _buildCustomMarker(
                  "tourEndingPoint",
                  LatLng(widget.waypoints[widget.waypoints.length - 1].latitude,
                      widget.waypoints[widget.waypoints.length - 1].longitude),
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                  "Tour Ending Point",
                  null,
                ),
              }
            },
            polylines:
                widget.withTrail ? _buildPolylines(polylineCoordinates) : {},
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            onTap: (LatLng latLng) {
              widget.onTapWaypoint(latLng);
            },
          ),
        ),
        if (widget.withTrail)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem("Start", Colors.green),
                _buildLegendItem("Middle", Colors.cyan),
                _buildLegendItem("End", Colors.red),
              ],
            ),
          ),
      ],
    );
  }
}
