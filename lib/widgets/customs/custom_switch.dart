import 'dart:core';

import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key, required this.onChanged});

  final Function(bool) onChanged;

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool _isOn = false;

  void _toggleSwitch(bool value) {
    setState(() {
      _isOn = value;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Multiple Choice ${_isOn ? 'Yes' : 'No'}',
          style: const TextStyle(fontSize: 15),
        ),
        Transform.scale(
          scale: 0.7,
          child: Switch(
            value: _isOn,
            onChanged: _toggleSwitch,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red[200],
          ),
        ),
      ],
    );
  }
}
