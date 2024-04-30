import 'package:flutter/material.dart';

class LocationContainer extends StatelessWidget {
  const LocationContainer({
    Key? key,
    required this.previewContent,
    this.isGettingLocation = false,
  }) : super(key: key);

  final Widget previewContent;
  final bool isGettingLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
      ),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: Container(
        child: isGettingLocation
            ? const CircularProgressIndicator()
            : previewContent,
      ),
    );
  }
}
