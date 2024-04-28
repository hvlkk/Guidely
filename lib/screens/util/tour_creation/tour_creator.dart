import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/screens/util/tour_creation/tour_creator_second.dart';

class TourCreatorScreen extends StatefulWidget {
  const TourCreatorScreen({super.key});

  @override
  State<TourCreatorScreen> createState() => _TourCreatorScreenState();
}

class _TourCreatorScreenState extends State<TourCreatorScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _tourTitleController = TextEditingController();
  final _tourDescriptionController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    setState(() {
      _selectedDate = picked!;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    setState(() {
      _selectedTime = picked!;
    });
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
    // validate the date
    if (_selectedDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a correct date.'),
        ),
      );
      return;
    }

    // navigate to the next screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TourCreatorSecondScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tour Creation', style: poppinsFont),
        // add an underline to the title
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Divider(
            color: MainColors.divider,
            thickness: 0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(
              'General',
              style: poppinsFont.copyWith(
                  fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            // add a text field for the tour name
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
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter your description here',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: MainColors.divider),
                  ),
                  fillColor: MainColors.textHint,
                ),
                keyboardType: TextInputType.multiline,
                controller: _tourDescriptionController,
                maxLines: 10,
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(
                  FocusNode(),
                );
              },
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
            const SizedBox(height: 50),
            // add a button to submit the tour
            ElevatedButton(
              onPressed: () {
                // submit the tour
                _submit();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(ButtonColors.primary),
              ),
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
