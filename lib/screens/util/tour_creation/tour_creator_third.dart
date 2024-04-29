import 'package:flutter/material.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator_template.dart';

class TourCreatorThirdScreen extends StatefulWidget {
  const TourCreatorThirdScreen({Key? key}) : super(key: key);

  @override
  State<TourCreatorThirdScreen> createState() => _TourCreatorThirdScreenState();
}

class _TourCreatorThirdScreenState extends State<TourCreatorThirdScreen> {
  @override
  Widget build(BuildContext context) {
    return TourCreatorTemplate(
      title: 'Tour Creation',
      body: const Column(
        children: [
          Center(
            child: Text(
              'Activities',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 25),
        ],
      ),
      isFinal: true,
      callBack: () {
        // Action to be performed when Submit button is pressed
      },
    );
  }
}
