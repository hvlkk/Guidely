// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/data/tour_creation_data.dart';
import 'package:guidely/models/data/tour_event_location.dart';
import 'package:guidely/models/data/waypoint.dart';
import 'package:guidely/models/utils/location_input.dart';
import 'package:guidely/screens/util/map.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator_template.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator_third.dart';
import 'package:guidely/widgets/customs/custom_location_container.dart';
import 'package:guidely/widgets/customs/custom_text_field.dart';
import 'package:http/http.dart' as http;

const apiKey = 'AIzaSyDKQj67ZoqcZ-UPXO1cnmGdYQ9wpKAoltI'; // to be changed

class TourCreatorSecondScreen extends StatefulWidget {
  const TourCreatorSecondScreen({
    super.key,
    required this.tourData,
  });

  final TourCreationData tourData;

  @override
  State<TourCreatorSecondScreen> createState() =>
      _TourCreatorSecondScreenState();
}

class _TourCreatorSecondScreenState extends State<TourCreatorSecondScreen> {
  List<Waypoint>? _pickedLocations;
  var _isGettingLocation = false;
  final _messageController = TextEditingController();

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  late final TourEventLocation startingLocation;

  @override
  void dispose() {
    super.dispose();
    _focusScopeNode.dispose();
  }

  Future<void> _savePlace(List<LatLng> waypoints) async {
    List<Waypoint> tempLocation = [];

    for (final LatLng waypoint in waypoints) {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${waypoint.latitude},${waypoint.longitude}&key=$apiKey');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get location')),
        );
        return;
      }

      final data = json.decode(response.body);
      final address = data['results'][0]['formatted_address'];

      final tourWaypoints = Waypoint(
        latitude: waypoint.latitude,
        longitude: waypoint.longitude,
        address: address,
      );
      tempLocation.add(tourWaypoints);
    }
    setState(() {
      _pickedLocations = tempLocation;
      _isGettingLocation = false;
      widget.tourData.copyWith(waypoints: _pickedLocations);
    });
  }

  void _selectOnMap() async {
    final pickedLocations = await Navigator.of(context).push<List<LatLng>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => const MapScreen(),
      ),
    );
    if (pickedLocations == null) {
      return;
    }

    _savePlace(pickedLocations);
  }

  String get locationImage {
    if (_pickedLocations == null || _pickedLocations!.isEmpty) {
      return '';
    }

    final firstMarker =
        'markers=color:red%7Clabel:A%7C${_pickedLocations!.first.latitude},${_pickedLocations!.first.longitude}';
    final lastMarker =
        'markers=color:black%7Clabel:S%7C${_pickedLocations!.last.latitude},${_pickedLocations!.last.longitude}';

    final middleMarkers = _pickedLocations!
        .sublist(1, _pickedLocations!.length - 1)
        .map((location) {
      final lat = location.latitude;
      final long = location.longitude;
      return 'markers=color:blue%7Clabel:M%7C$lat,$long';
    }).join('&');

    return 'https://maps.googleapis.com/maps/api/staticmap?center=${_pickedLocations!.map((e) => '${e.latitude},${e.longitude}').join('|')}&zoom=16&size=600x300&maptype=roadmap&$firstMarker&$middleMarkers&$lastMarker&key=$apiKey';
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent;

    if (_pickedLocations != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
      );
    } else {
      previewContent = Text('No location chosen', style: poppinsFont);
    }

    return TourCreatorTemplate(
      title: 'Tour Creation',
      body: Column(
        children: [
          Text(
            'Location',
            style: poppinsFont.copyWith(
                fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
          LocationContainer(
            previewContent: previewContent,
            isGettingLocation: _isGettingLocation,
          ),
          const SizedBox(height: 10),
          LocationInput(
            onSelectMap: () {
              _selectOnMap();
            },
          ),
          const SizedBox(height: 10),
          CustomTextField(
            header: 'Message to participants',
            controller: _messageController,
          ),
        ],
      ),
      callBack: () {
        final updatedTourData = widget.tourData.copyWith(
          messageToParticipants: _messageController.text,
          waypoints: _pickedLocations,
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TourCreatorThirdScreen(
              tourData: updatedTourData,
            ),
          ),
        );
      },
    );
  }
}
