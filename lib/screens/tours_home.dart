import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ToursHomeScreen extends StatelessWidget {
  const ToursHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guidely'),
        // add logout button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome to Guidely!'),
      ),
    );
  }
}
