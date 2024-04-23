import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/models/user.dart' as myuser;

final userDataProvider = FutureProvider.autoDispose(
  (ref) async {
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    final data = userData.data() as Map<String, dynamic>;

    final newUser = myuser.User(
      username: data['username'],
      imageUrl: data['imageUrl'],
      email: data['email'],
      uid: data['uid'],
      isTourGuide: data['isTourGuide'] ?? false,
      registrationData: data['registrationData'],
    );

    return newUser;
  },
);
