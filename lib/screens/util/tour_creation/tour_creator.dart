// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/data/tour_creation_data.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator_second.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator_template.dart';
import 'package:guidely/widgets/customs/custom_text_field.dart';

class TourCreatorScreen extends StatefulWidget {
  const TourCreatorScreen({super.key});

  @override
  _TourCreatorScreenState createState() => _TourCreatorScreenState();
}

class _TourCreatorScreenState extends State<TourCreatorScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _selectedDuration = const TimeOfDay(hour: 2, minute: 0);
  final _tourTitleController = TextEditingController();
  final _tourDescriptionController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDuration(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDuration,
    );
    if (picked != null && picked != _selectedDuration) {
      setState(() {
        _selectedDuration = picked;
      });
    }
  }

  void _submit() {
    // validate the form
    if (_tourTitleController.text.isEmpty ||
        _tourDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all the fields.'),
        ),
      );
      return;
    }
    // // validate the date
    // DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    // if (_selectedDate.isBefore(yesterday)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please select a correct date.'),
    //     ),
    //   );
    //   return;
    // }

    final tourData = TourCreationData(
      title: _tourTitleController.text,
      description: _tourDescriptionController.text,
      startDate: _selectedDate,
      startTime: _selectedTime,
      messageToParticipants: '',
    );

    // navigate to the next screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TourCreatorSecondScreen(tourData: tourData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TourCreatorTemplate(
      title: 'Tour Creation',
      body: Column(
        children: [
          Text(
            'General',
            style: poppinsFont.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Tour name',
              hintText: 'Enter the name of the tour',
              border: OutlineInputBorder(),
            ),
            controller: _tourTitleController,
          ),
          const SizedBox(height: 25),
          GestureDetector(
            child: CustomTextField(
              header: 'Tour description',
              controller: _tourDescriptionController,
            ),
          ),
          Row(
            children: [
              // add date picker for the tour start date
              Expanded(
                child: InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start date',
                      hintText: 'Enter the start date of the tour',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text("${_selectedDate.toLocal()}".split(' ')[0]),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: () => _selectTime(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start time',
                      hintText: 'Enter the start time of the tour',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(_selectedTime.format(context)),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: () => _selectDuration(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Duration',
                hintText: 'Enter the duration of the tour',
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    '${_selectedDuration.hour} h ${_selectedDuration.minute} min',
                  ),
                  const Icon(Icons.timer),
                ],
              ),
            ),
          ),
        ],
      ),
      callBack: _submit,
    );
  }
}
