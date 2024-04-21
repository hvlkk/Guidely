import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';

class RegistrationScreenTemplate extends StatelessWidget {
  final String title;
  final String step;
  final String instruction;
  final Widget child;

  const RegistrationScreenTemplate({
    super.key,
    required this.title,
    required this.step,
    required this.instruction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: poppinsFont.copyWith(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Title(
                color: MainColors.accent,
                child: Text(
                  step,
                  style: poppinsFont.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  instruction,
                  style: poppinsFont.copyWith(
                    fontSize: 15,
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
