import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guidely/screens/auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:guidely/screens/tours_home.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guidely',
      // emits a new stream of data whenever the user logs in or out
      home: StreamBuilder(
          // listens to the auth state changes
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            // snapshot is the data that has the token of the authenticated user
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              return const ToursHomeScreen();
            }
            return const AuthScreen();
          }),
    );
  }
}
