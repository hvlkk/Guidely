import 'package:flutter/material.dart';
import 'package:guidely/models/entities/user.dart';

class HostProfileScreen extends StatelessWidget {
  const HostProfileScreen({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Profile'),
      ),
      body: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.imageUrl),
            ),
            const SizedBox(height: 20),
            Text(user.username),
            const SizedBox(height: 20),
            Text(user.email),
          ],
        ),
      ),
    );
  }
}
