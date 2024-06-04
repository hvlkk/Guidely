import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';

class TourFilterDropdown extends StatefulWidget {
  final void Function(String) onValueChanged;

  const TourFilterDropdown(
      {super.key,
      required this.onValueChanged,
      required Null Function(String? newValue) onChanged});

  @override
  _TourFilterDropdownState createState() => _TourFilterDropdownState();
}

class _TourFilterDropdownState extends State<TourFilterDropdown> {
  String _selectedFilter = 'Nearby';

  final List<String> _filterOptions = [
    'Nearby',
    'Highest Rated',
    // 'Most Popular', // SOMETHING CREATIVE (EXTRA)
    'Activities',
    'Starting Soon',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MainColors.background,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              dropdownColor: MainColors.background,
              value: _selectedFilter,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 36,
              elevation: 16,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              underline: Container(
                height: 0, // Hide the default underline
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFilter = newValue;
                  });
                  widget.onValueChanged(newValue);
                }
              },
              items:
                  _filterOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
