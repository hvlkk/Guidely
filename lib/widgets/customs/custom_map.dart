import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/models/data/waypoint.dart';
import 'package:guidely/utils/location_finder.dart';
import 'package:http/http.dart' as http;

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
  Marker? _organizerMarker;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation) {
      _updateUserLocation();
      _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _updateUserLocation();
      });
    }
    _loadOrganizerMarker();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateUserLocation() async {
    final position = await LocationFinder.getLocation();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _loadOrganizerMarker() async {
    try {
      final marker = await _buildCustomOrganizerMarker(widget.organizerIcon);
      setState(() {
        _organizerMarker = marker;
      });
      print("Organizer marker loaded and set");
    } catch (e) {
      print("Error loading organizer marker: $e");
    }
  }

  Future<Uint8List> _getBytesFromNetworkImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      print("Image downloaded, byte length: ${bytes.length}");
      return bytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<Uint8List> _getCircularImageWithBorder(Uint8List bytes,
      {double size = 175, double borderWidth = 10}) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      return completer.complete(img);
    });
    final ui.Image image = await completer.future;
    print("Image processed to ui.Image");

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;

    // Draw the border
    final double radius = size / 2;
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );

    // Draw the circular image
    paint.imageFilter = ui.ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1);
    paint.shader = ImageShader(
        image, TileMode.clamp, TileMode.clamp, Matrix4.identity().storage);
    canvas.drawCircle(
      Offset(radius, radius),
      radius - borderWidth,
      paint,
    );

    // Get the image bytes
    final ui.Image finalImage = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    print("Circular image with border processed");
    return byteData!.buffer.asUint8List();
  }

  Future<Marker> _buildCustomOrganizerMarker(String organizerIcon) async {
    // Get the organizer's icon as a Uint8List
    final Uint8List markerIconBytes =
        await _getBytesFromNetworkImage(organizerIcon);
    print("Organizer icon downloaded");

    // Process the image to make it circular with a border
    final Uint8List circularMarkerIcon =
        await _getCircularImageWithBorder(markerIconBytes);
    print("Organizer icon processed to circular image");

    // Create a BitmapDescriptor from the Uint8List
    final BitmapDescriptor organizerMarkerIcon =
        BitmapDescriptor.fromBytes(circularMarkerIcon);
    print("BitmapDescriptor created");

    // Return the custom marker
    return Marker(
      markerId: const MarkerId('organizer'),
      position:
          LatLng(widget.waypoints[0].latitude, widget.waypoints[0].longitude),
      icon: organizerMarkerIcon, // Use the BitmapDescriptor
      infoWindow: const InfoWindow(title: 'Organizer'),
      anchor: Offset(0.5, 1.65), // Position the icon at the top of the marker
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
                ),
              if (widget.onTourSession) ...{
                if (_organizerMarker != null) _organizerMarker!,
                _buildCustomMarker(
                  "tourStartingPoint",
                  LatLng(widget.waypoints[1].latitude,
                      widget.waypoints[1].longitude),
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  "Tour Starting Point",
                ),
                _buildCustomMarker(
                  "tourEndingPoint",
                  LatLng(widget.waypoints[widget.waypoints.length - 1].latitude,
                      widget.waypoints[widget.waypoints.length - 1].longitude),
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                  "Tour Ending Point",
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
