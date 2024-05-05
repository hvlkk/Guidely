import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';

class TourCreatorTemplate extends StatelessWidget {
  const TourCreatorTemplate({
    super.key,
    required this.title,
    required this.body,
    required this.callBack,
    this.isFinal = false,
  });

  final String title;
  final Widget body;
  final bool isFinal;
  final VoidCallback callBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: poppinsFont),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              body,
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: callBack,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(ButtonColors.primary),
                ),
                child: Text(
                  isFinal ? 'Submit' : 'Next',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
