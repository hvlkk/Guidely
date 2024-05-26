import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SessionBloc {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadImage(File pickedImage, String sessionId) async {
    try {
      // Generate a unique identifier for the image
      final String uuid = const Uuid().v4();

      // Define the path for the image in Firebase Storage
      final String imagePath = 'user_images/$sessionId/$uuid.jpg';

      // Upload the image file to Firebase Storage
      final UploadTask uploadTask = _firebaseStorage.ref().child(imagePath).putFile(pickedImage);
      
      // Get the download URL for the uploaded image
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String imageURL = await taskSnapshot.ref.getDownloadURL();
      
      return imageURL;
    } catch (error) {
      // Handle errors here, if any
      print('Error uploading image: $error');
      return '';
    }
  }

  Future<void> addMedia(BuildContext context, File pickedImage, String sessionId) async {
    try {
      // Upload the image and get its URL
      final String imageURL = await uploadImage(pickedImage, sessionId);

      // Add the image URL to the Firestore document
      await FirebaseFirestore.instance.collection('sessions').doc(sessionId).update({
        'mediaUrls': FieldValue.arrayUnion([imageURL]),
      });
      
      print('Media added successfully');
    } catch (error) {
      // Handle errors here, if any
      print('Error adding media: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
  }
}
