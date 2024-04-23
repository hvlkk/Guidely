import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/providers/user_data_provider.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ToursScreenState createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  final List<String> tabNames = ['Past tours', 'Live tours', 'Upcoming tours'];

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tours'),
      ),
      body: userDataAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (userData) {
          final isTourGuide = userData.isTourGuide;

          return DefaultTabController(
            length: tabNames.length,
            child: Scaffold(
              appBar: const TabBar(
                tabs: [
                  Tab(text: 'Past'),
                  Tab(text: 'Live now'),
                  Tab(text: 'Upcoming'),
                ],
              ),
              // TODO: to be removed later
              body: TabBarView(
                children: [
                  isTourGuide
                      ? _buildTourGuideContent()
                      : _buildTabContent('No ${tabNames[0]}'),
                  isTourGuide
                      ? _buildTourGuideContent()
                      : _buildTabContent('No ${tabNames[1]}'),
                  isTourGuide
                      ? _buildTourGuideContent()
                      : _buildTabContent('No ${tabNames[2]}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(String message) {
    return Center(
      child: Text(message),
    );
  }

  Widget _buildTourGuideContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Nothing to see here, why don\'t you add a tour?',
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // navigate to the add tour screen
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(ButtonColors.primary),
            ),
            child: const Text(
              'Add a tour',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
