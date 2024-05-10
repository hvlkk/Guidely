import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/models/data/tour_event_location.dart';

class MapSelectorScreen extends StatefulWidget {
  const MapSelectorScreen({
    super.key,
    this.initialLocation = const TourEventLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: 'Googleplex',
      name: 'Googleplex',
    ),
    this.isSelecting = true,
    this.maxWaypoints = 50,
  });

  final TourEventLocation? initialLocation;
  final bool isSelecting;
  final int maxWaypoints; // Maximum number of waypoints
  @override
  State<MapSelectorScreen> createState() => _MapSelectorScreenState();
}

class _MapSelectorScreenState extends State<MapSelectorScreen> {
  final List<LatLng> _pickedLocations = [];

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
                if (widget.maxWaypoints == 1) {
                  // If maxWaypoints is 1, return just the LatLng
                  if (_pickedLocations.isEmpty) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop(_pickedLocations.first);
                  }
                } else {
                  // If maxWaypoints is more than 1, return the list of LatLngs
                  Navigator.of(context).pop(_pickedLocations);
                }
              },
            ),
        ],
      ),
      body: GoogleMap(
        onTap: (position) {
          if (_pickedLocations.length < widget.maxWaypoints) {
            setState(() {
              _pickedLocations.add(position);
            });
          }
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.initialLocation!.latitude,
            widget.initialLocation!.longitude,
          ),
          zoom: 16,
        ),
        markers: _pickedLocations
            .asMap()
            .map(
              (index, location) => MapEntry(
                index.toString(),
                Marker(
                  markerId: MarkerId(index.toString()),
                  position: location,
                ),
              ),
            )
            .values
            .toSet(),
      ),
    );
  }
}
