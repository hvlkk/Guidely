import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/models/data/tour_event_location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.initialLocation = const TourEventLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: 'Googleplex',
      name: 'Googleplex',
    ),
    this.isSelecting = true,
  });

  final TourEventLocation? initialLocation;
  final bool isSelecting;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? 'Select Location' : 'Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
            ),
        ],
      ),
      body: GoogleMap(
        onTap: (position) {
          setState(() {
            _pickedLocation = position;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.initialLocation!.latitude,
            widget.initialLocation!.longitude,
          ),
          zoom: 16,
        ),
        markers: (_pickedLocation == null && widget.isSelecting)
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('m1'),
                  position: _pickedLocation != null
                      ? _pickedLocation!
                      : LatLng(
                          widget.initialLocation!.latitude,
                          widget.initialLocation!.longitude,
                        ),
                ),
              },
      ),
    );
  }
}
