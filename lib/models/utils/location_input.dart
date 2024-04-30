import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LocationInput extends StatefulWidget {
  LocationInput({
    super.key,
    this.onSelectMap,
    this.activateCurrentLocation = true,
  });

  void Function()? onSelectMap;

  final bool activateCurrentLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton.icon(
            onPressed: widget.onSelectMap ?? () {},
            icon: const Icon(Icons.location_on),
            label: const Text('Select on map'),
          ),
        ]),
      ],
    );
  }
}
