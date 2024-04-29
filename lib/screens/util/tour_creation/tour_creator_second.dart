import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/location_input.dart';
import 'package:guidely/models/tour_event_location.dart';
import 'package:guidely/screens/util/map.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

const API_KEY = 'AIzaSyDKQj67ZoqcZ-UPXO1cnmGdYQ9wpKAoltI'; // to be changed

class TourCreatorSecondScreen extends StatefulWidget {
  const TourCreatorSecondScreen({super.key});

  @override
  State<TourCreatorSecondScreen> createState() =>
      _TourCreatorSecondScreenState();
}

class _TourCreatorSecondScreenState extends State<TourCreatorSecondScreen> {
  TourEventLocation? _pickedLocation;
  var _isGettingLocation = false;

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  Future<void> _savePlace(double lat, double long) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$API_KEY');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      const SnackBar(content: Text('Failed to get location'));
      return;
    }

    final data = json.decode(response.body);
    final address = data['results'][0]['formatted_address'];

    TourEventLocation tour_location = TourEventLocation(
      name:
          'Current Location', // to be changed later with the name we receive from the previous screen
      latitude: lat,
      longitude: long,
      address: address,
    );

    setState(
      () {
        _pickedLocation = tour_location;
        _isGettingLocation = false;
      },
    );
  }

  void _getCurrentLocation() async {
    Location location = new Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(
      () {
        _isGettingLocation = true;
      },
    );

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final long = locationData.longitude;

    _savePlace(lat!, long!);
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => const MapScreen(),
      ),
    );
    if (pickedLocation == null) {
      return;
    }
    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }

    final lat = _pickedLocation!.latitude;
    final long = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:S%7C$lat,$long&key=$API_KEY';
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent;

    if (_pickedLocation != null) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Tour Creation', style: poppinsFont),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Location',
                style: poppinsFont.copyWith(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                child: Container(
                  child: _isGettingLocation
                      ? const CircularProgressIndicator()
                      : previewContent,
                ),
              ),
              const SizedBox(height: 10),
              LocationInput(
                onCurrentLocation: () {
                  _getCurrentLocation();
                },
                onSelectMap: () {
                  _selectOnMap();
                },
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  if (!_focusScopeNode.hasPrimaryFocus) {
                    _focusScopeNode.unfocus();
                  }
                },
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Message to participants',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: MainColors.divider),
                    ),
                    fillColor: MainColors.textHint,
                  ),
                  cursorHeight: 20,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(ButtonColors.primary),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
