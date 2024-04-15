import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, signup }

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColors.background,
      body: Center(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: poppinsFont,
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: poppinsFont,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
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
    );
  }
}
