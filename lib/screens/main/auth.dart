// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidely/blocs/main/auth_bloc.dart';
import 'package:guidely/widgets/models/user_image_picker_widget.dart';
import 'package:guidely/misc/common.dart';

enum AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthBloc _authBloc = AuthBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _authBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: StreamBuilder<bool>(
                      stream: _authBloc.isLoadingStream,
                      builder: (context, snapshot) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _authBloc.authMode == AuthMode.signup
                                ? Column(
                                    children: [
                                      UserImagePickerWidget(
                                        onImagePicked: _authBloc.setUserImage,
                                      ),
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
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MainColors.accent,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@') ||
                                    !_isValidEmail(value)) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              controller: _authBloc.emailController,
                            ),
                            _authBloc.authMode == AuthMode.signup
                                ? TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      labelStyle: poppinsFont,
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: MainColors.accent,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.length < 3) {
                                        return 'Username must be at least 3 characters long.';
                                      }
                                      return null;
                                    },
                                    controller: _authBloc.usernameController,
                                  )
                                : Container(),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: poppinsFont,
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MainColors.accent,
                                  ), // Change color to whatever you want
                                  // Change color to whatever you want
                                ),
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
                              controller: _authBloc.passwordController,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _authBloc.submit,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    ButtonColors.primary),
                              ),
                              child: Text(
                                _authBloc.authMode == AuthMode.login
                                    ? 'Login'
                                    : 'Signup',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _authBloc.toggleAuthMode();
                                setState(() {});
                              },
                              child: Text(
                                _authBloc.authMode == AuthMode.login
                                    ? 'Create new account'
                                    : 'Already have an account?',
                                style: poppinsFont.copyWith(
                                  color: MainColors.accent,
                                ),
                              ),
                            ),
                            StreamBuilder<String>(
                              stream: _authBloc.errorStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data!,
                                    style: TextStyle(color: Colors.red),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ],
                        );
                      },
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

  bool _isValidEmail(String? email) {
    if (email == null) {
      return false;
    }
    email = email.trim();
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,20}$');

    return emailRegex.hasMatch(email);
  }
}
