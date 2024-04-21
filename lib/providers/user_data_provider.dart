import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/models/user.dart' as myuser;

final userDataProvider = FutureProvider.autoDispose((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  final userData =
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();

  final data = userData.data() as Map<String, dynamic>;
  final userDataMap = data[user?.uid] as Map<String, dynamic>;

  return myuser.User(
    username: userDataMap['username'],
    imageUrl: userDataMap['imageUrl'],
    email: userDataMap['email'],
    uid: userDataMap['uid'],
  );
});
