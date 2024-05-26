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
          child: Center(child: Text('Map Placeholder')),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Guide\'s Current Location'),
            IconButton(
              icon: Icon(Icons.location_on),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
