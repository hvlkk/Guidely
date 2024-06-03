// ignore_for_file: must_be_immutable
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guidely/models/entities/notification.dart' as myNoti;
import 'package:guidely/widgets/entities/notification_list_item.dart';

@immutable
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.notifications});

  final List<myNoti.Notification> notifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blueGrey,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications to display',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: min(10, notifications.length),
              itemBuilder: (context, index) {
                return NotificationListItem(notification: notifications[index]);
              },
            ),
    );
  }
}
