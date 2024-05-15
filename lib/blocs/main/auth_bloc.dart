import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:guidely/screens/main/auth.dart';
import 'package:guidely/models/entities/user.dart'
    // ignore: library_prefixes
    as TourUser; // Renamed to avoid conflict with FirebaseAuth

class AuthBloc {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFunctions _firebaseFunctions = FirebaseFunctions.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthMode authMode = AuthMode.login;
  File? _userImageFile;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  TextEditingController get emailController => _emailController;
  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;

  get _enteredEmail => _emailController.text;
  get _enteredUsername => _usernameController.text;
  get _enteredPassword => _passwordController.text;

  final StreamController<bool> _isLoadingController = StreamController<bool>();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  final StreamController<String> _errorController = StreamController<String>();
  Stream<String> get errorStream => _errorController.stream;

  void dispose() {
    _isLoadingController.close();
    _errorController.close();
  }

  void toggleAuthMode() {
    authMode = authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
  }

  void setUserImage(File? image) {
    _userImageFile = image;
  }

  void submit() async {
    try {
      if (authMode == AuthMode.login) {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        await _signUp();
      }
    } on FirebaseAuthException catch (e) {
      _errorController.add(e.message ?? 'An error occurred');
    } catch (e) {
      _errorController.add('An unexpected error occurred');
    }
  }

  Future<void> _signUp() async {
    final isValid = await _validateSignup();
    if (!isValid) {
      return;
    }

    final userCredentials = await _firebaseAuth.createUserWithEmailAndPassword(
      email: _enteredEmail,
      password: _enteredPassword,
    );

    final storageRef = _firebaseStorage
        .ref()
        .child('user_images')
        .child('${userCredentials.user!.uid}.jpg');

    await storageRef.putFile(_userImageFile!);
    final imageURL = await storageRef.getDownloadURL();
    final token = await _getFcmToken();

    final newUser = TourUser.User(
      uid: userCredentials.user!.uid,
      username: _enteredUsername,
      email: _enteredEmail,
      imageUrl: imageURL,
      bookedTours: [],
      organizedTours: [],
      fcmToken: token,
    );
    await FirebaseFirestore.instance.collection('users').doc(newUser.uid).set(
          newUser.toMap(),
        );
  }

  Future<bool> _validateSignup() async {
    if (_userImageFile == null) {
      _errorController.add('Please pick an image.');
      return false;
    }

    final usernameAvailable = await _checkUsernameAvailability();
    if (!usernameAvailable) {
      _errorController.add('Username already exists.');
      return false;
    }

    return true;
  }

  Future<String> _getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    return token ?? '';
  }

  Future<bool> _checkUsernameAvailability() async {
    final callable =
        _firebaseFunctions.httpsCallable('checkUsernameAvailability');
    final response = await callable({'username': _enteredUsername});
    return response.data;
  }
}
