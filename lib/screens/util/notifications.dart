// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guidely/models/entities/notification.dart' as myNoti;
import 'package:guidely/widgets/entities/notification_list_item.dart';

@immutable
class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key, required this.notifications});

  List<myNoti.Notification> notifications;

  @override
  Widget build(BuildContext context) {
    notifications.sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView.builder(
        itemCount: max(10, notifications.length),
        itemBuilder: (context, index) {
          return NotificationListItem(notification: notifications[index]);
        },
      ),
    );
  }
}
