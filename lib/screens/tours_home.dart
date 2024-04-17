import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';

class ToursHomeScreen extends StatelessWidget {
  const ToursHomeScreen({Key? key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUser() async {
    final user = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final userData = snapshot.data;
        final finalJsonData = userData!.data()?.entries;
        final username = finalJsonData?.first.value['username'];
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Guidely',
              style: TextStyle(
                  fontFamily: poppinsFont.fontFamily,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
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
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                        finalJsonData?.first.value['imageUrl'],
                      ),
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
              )
            ],
          ),
        );
      },
    );
  }
}
