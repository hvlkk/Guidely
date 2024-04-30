import 'package:flutter/material.dart';

class CustomNavigator extends StatelessWidget {
  final int selectedIndex;
  final List<Widget> screens;
  final Function(int) onDestinationSelected;

  const CustomNavigator({
    super.key,
    required this.selectedIndex,
    required this.screens,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: screens[selectedIndex]),
        BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onDestinationSelected,
          items: const [
            BottomNavigationBarItem(
              label: 'Tours',
              icon: Icon(Icons.car_repair),
            ),
            BottomNavigationBarItem(
              label: 'Explore',
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ],
    );
  }
}
