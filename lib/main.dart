// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/screens/main/auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:guidely/widgets/customs/custom_navigator.dart';
import 'package:guidely/screens/main/profile.dart';
import 'package:guidely/screens/main/tours.dart';
import 'package:guidely/screens/main/tours_home.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

enum NavigationIndex {
  tours,
  explore,
  profile,
}

class _MainAppState extends State<MainApp> {
  // this will be used to keep track of the selected index of the
  // bottom navigation bar
  late NavigationIndex _index;

  @override
  void initState() {
    super.initState();
    _index = NavigationIndex.explore;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guidely',
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            // this by default will navigate to the tours screen, which is the main screen
            // once the user is authenticated or he has a session token stored.
            return CustomNavigator(
              selectedIndex: _index.index,
              screens: const [
                ToursScreen(),
                ToursHomeScreen(),
                ProfileScreen(),
              ],
              onDestinationSelected: (index) {
                setState(
                  () {
                    _index = NavigationIndex.values[index];
                  },
                );
              },
            );
          }
          return const AuthScreen(); // if the user is not authenticated, redirect to the auth screen
        },
      ),
    );
  }
}
