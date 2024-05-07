import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserService {
  static Future<void> updateUserData(
      String uid, Map<String, dynamic> data, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
            data,
            SetOptions(merge: true), // Merge with existing data
          );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
  }
}
