import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:guidely/widgets/user_image_picker_widget.dart';
import 'package:guidely/misc/common.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, signup }

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;

  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    try {
      if (_authMode == AuthMode.login) {
        _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else if (_authMode == AuthMode.signup) {
        // Signup
        _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      }
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please check your credentials.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents the screen from resizing when the keyboard is shown
      backgroundColor: MainColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Guidely',
                style: poppinsFont.copyWith(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SvgPicture.asset(
                'assets/images/login_screen_logo.svg',
                height: 150,
              ),
              Card(
                margin: const EdgeInsets.all(20),
                color: MainColors.background,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _authMode == AuthMode.signup
                            ? Column(
                                children: [
                                  const UserImagePickerWidget(),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Photo Profile',
                                    style: poppinsFont.copyWith(
                                      color: MainColors.textHint,
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: poppinsFont,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onSaved: (newValue) => _enteredEmail = newValue!,
                        ),
                        _authMode == AuthMode.signup
                            ? TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: poppinsFont,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length < 3) {
                                    return 'Username must be at least 3 characters long.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) =>
                                    _enteredUsername = newValue!,
                              )
                            : Container(),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: poppinsFont,
                          ),
                          enableSuggestions: true,
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 6) {
                              return 'Password must be at least 6 characters long.';
                            }
                            return null;
                          },
                          onSaved: (newValue) => _enteredPassword = newValue!,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(ButtonColors.primary),
                          ),
                          child: Text(
                            _authMode == AuthMode.login ? 'Login' : 'Signup',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_authMode == AuthMode.login) {
                                _authMode = AuthMode.signup;
                              } else {
                                _authMode = AuthMode.login;
                              }
                            });
                          },
                          child: Text(
                            _authMode == AuthMode.login
                                ? 'Create new account'
                                : 'Already have an account?',
                            style: poppinsFont.copyWith(
                              color: MainColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
