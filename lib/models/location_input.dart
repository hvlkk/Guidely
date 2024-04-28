import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LocationInput extends StatefulWidget {
  LocationInput({super.key, required this.onCurrentLocation});

  void Function() onCurrentLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          TextButton(
            onPressed: () {},
            child: TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Current Location'),
              onPressed: widget.onCurrentLocation,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Select on map'),
              onPressed: () {},
            ),
          ),
        ]),
      ],
    );
  }
}
