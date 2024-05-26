// Map Section
import 'package:flutter/material.dart';

class MapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          color: Colors.grey,
          child: const Center(child: Text('Map Placeholder')),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Guide\'s Current Location'),
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
