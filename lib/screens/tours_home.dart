// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/screens/notifications.dart';
import 'package:guidely/screens/profile.dart';
import 'package:guidely/screens/tours.dart';

class ToursHomeScreen extends StatefulWidget {
  const ToursHomeScreen({super.key});

  @override
  _ToursHomeScreenState createState() => _ToursHomeScreenState();
}

class _ToursHomeScreenState extends State<ToursHomeScreen> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final userData = snapshot.data!;
          final finalJsonData = userData.data()?.entries;

          final username = finalJsonData?.first.value['username'];
          final imageUrl = finalJsonData?.first.value['imageUrl'];

          if (finalJsonData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Guidely',
                style: TextStyle(
                  fontFamily: poppinsFont.fontFamily,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Welcome, $username!',
                          style: TextStyle(
                            fontFamily: poppinsFont.fontFamily,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  GestureDetector(
                    child: const Icon(Icons.notifications, size: 30),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) {
                          return const NotificationsScreen();
                        },
                      ));
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return Container(); // Return an empty container if snapshot has no data
      },
    );
  }
}

// Define your screens list outside of ToursHomeScreen
final screens = [
  const ToursScreen(),
  const ToursHomeScreen(),
  const ProfileScreen(),
];
