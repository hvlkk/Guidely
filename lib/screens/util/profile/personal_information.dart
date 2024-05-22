import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/utils/language.dart';
import 'package:guidely/models/utils/tour_category.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/repositories/user_repository.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:intl/intl.dart';

final _formatter = DateFormat.yMMMd();

class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() {
    return _PersonalInformationScreenState();
  }
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  DateTime? _dateOfBirth;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'GR');
  final TextEditingController _phoneNumberController = TextEditingController();
  final Set<Language> _selectedLanguages = {};
  final Set<TourCategory> _selectedCategories = {};
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = await ref.read(userDataProvider.future);
    setState(() {
      _uid = user.uid;
      _firstName = user.firstName;
      _lastName = user.lastName;
      _dateOfBirth = user.dateOfBirth;
      _phoneNumberController.text = user.phoneNumber ?? '';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100, now.month, now.day),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Map<String, dynamic> formToMap() {
    return {
      'firstName': _firstName,
      'lastName': _lastName,
      'dateOfBirth': _dateOfBirth,
      'phoneNumber': _phoneNumber,
    };
  }

  void _saveInformation() async {
    if (!_formKey.currentState!.validate()) {
      print('Form failed to validate.');
      return;
    }

    _formKey.currentState!.save();
    print('Form data: $_firstName, $_lastName, $_dateOfBirth, $_phoneNumber');

    UserRepository().updateUserData(_uid, formToMap());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal information saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColors.background,
      appBar: AppBar(
        title: const Text('Personal Information'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  color: const Color.fromARGB(255, 255, 235, 210),
                  margin: const EdgeInsets.all(6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Personal Details',
                            style: TextStyle(
                                fontFamily: poppinsFont.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 75, 75, 75)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your personal details will only be shared with the guides of the tours you participate in, in order to enhance your experience. Other participants will not have access to this information.',
                          style: TextStyle(
                            fontFamily: poppinsFont.fontFamily,
                            fontSize: 14,
                            color: const Color.fromARGB(255, 80, 80, 80),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          autocorrect: true,
                          decoration: InputDecoration(
                            label: Text(
                              'First Name',
                              style: TextStyle(
                                fontFamily: poppinsFont.fontFamily,
                                fontSize: 14,
                                color: const Color.fromARGB(255, 80, 80, 80),
                              ),
                            ),
                          ),
                          initialValue: _firstName,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length >= 2) {
                              return null;
                            }
                            return 'Name must be at least 2 characters long.';
                          },
                          onSaved: (value) {
                            _firstName = value;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          autocorrect: true,
                          decoration: InputDecoration(
                            label: Text('Last Name',
                                style: TextStyle(
                                  fontFamily: poppinsFont.fontFamily,
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 80, 80, 80),
                                )),
                          ),
                          initialValue: _lastName,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length >= 2) {
                              return null;
                            }
                            return 'Name must be at least 2 characters long.';
                          },
                          onSaved: (value) {
                            _lastName = value;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Date of Birth',
                                style: TextStyle(
                                  fontFamily: poppinsFont.fontFamily,
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 80, 80, 80),
                                )),
                            if (_dateOfBirth != null)
                              Text(_formatter.format(_dateOfBirth!),
                                  style: TextStyle(
                                    fontFamily: poppinsFont.fontFamily,
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 80, 80, 80),
                                  )),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                _selectDate(context);
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        InternationalPhoneNumberInput(
                          textStyle: TextStyle(
                            fontFamily: poppinsFont.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 80, 80, 80),
                          ),
                          onInputChanged: (value) {
                            _phoneNumber = value;
                          },
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            useBottomSheetSafeArea: true,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          initialValue: _phoneNumber,
                          textFieldController: _phoneNumberController,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null) {
                              return null;
                            }
                            print('Validator: $value');
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: const Color.fromARGB(255, 255, 235, 210),
                  margin: const EdgeInsets.all(6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Preferences',
                            style: TextStyle(
                                fontFamily: poppinsFont.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 75, 75, 75)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Select your preferred tour categories and languages. Only tours that match your preferences will be displayed.',
                          style: TextStyle(
                            fontFamily: poppinsFont.fontFamily,
                            fontSize: 14,
                            color: const Color.fromARGB(255, 80, 80, 80),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Languages',
                            style: TextStyle(
                                fontFamily: poppinsFont.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 75, 75, 75)),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: double.infinity,
                            maxHeight: 100,
                          ),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              childAspectRatio: 1 / 0.3,
                            ),
                            itemCount: languages.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CheckboxListTile(
                                title: Text(
                                  languages[index].name,
                                  style: TextStyle(
                                    fontFamily: poppinsFont.fontFamily,
                                    fontSize: 13,
                                    color:
                                        const Color.fromARGB(255, 80, 80, 80),
                                  ),
                                ),
                                value: _selectedLanguages
                                    .contains(languages[index]),
                                onChanged: (value) {
                                  setState(
                                    () {
                                      if (value!) {
                                        _selectedLanguages
                                            .add(languages[index]);
                                      } else {
                                        _selectedLanguages
                                            .remove(languages[index]);
                                      }
                                    },
                                  );
                                },
                                contentPadding: EdgeInsets.zero,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tour Categories',
                            style: TextStyle(
                                fontFamily: poppinsFont.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 75, 75, 75)),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: double.infinity,
                            maxHeight: 280,
                          ),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: 1 / 0.3,
                            ),
                            itemCount: tourCategories.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(children: [
                                Icon(tourCategoryToIcon[tourCategories[index]]),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text(
                                      tourCategoryToString[
                                          tourCategories[index]]!,
                                      style: TextStyle(
                                        fontFamily: poppinsFont.fontFamily,
                                        fontSize: 13,
                                        color: const Color.fromARGB(
                                            255, 80, 80, 80),
                                      ),
                                    ),
                                    value: _selectedCategories
                                        .contains(tourCategories[index]),
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          if (value!) {
                                            _selectedCategories
                                                .add(tourCategories[index]);
                                          } else {
                                            _selectedCategories
                                                .remove(tourCategories[index]);
                                          }
                                        },
                                      );
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveInformation,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(ButtonColors.primary),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
