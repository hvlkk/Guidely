import 'package:flutter/material.dart';

class TourCreatorThirdScreen extends StatefulWidget {
  const TourCreatorThirdScreen({super.key});

  @override
  State<TourCreatorThirdScreen> createState() => _TourCreatorThirdScreenState();
}

class _TourCreatorThirdScreenState extends State<TourCreatorThirdScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Tour'),
      ),
      body: const Center(
        child: Text('Third Screen'),
      ),
    );
  }
}
