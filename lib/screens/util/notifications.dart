import 'package:flutter/material.dart';
import 'package:guidely/models/entities/notification.dart' as myNoti;
import 'package:guidely/widgets/entities/notification_list_item.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  // CREATE DUMMY NOTIS
  final List<myNoti.Notification> notifications = [
    myNoti.Notification(
      title: 'Important update',
      message: 'The meeting point for your tour has changed. Please check ...',
      date: DateTime.now(),
      uid: '1',
    ),
    myNoti.Notification(
      title: 'Reminder',
      message: 'Just a reminder that tomorrow\'s tour is scheduled to start at 10:00 AM. Be sure to wear comfortable...',
      date: DateTime.now().subtract(Duration(hours: 5)),
      uid: '2',
    ),
    myNoti.Notification(
      title: 'Guidely Reminder',
      message: 'We hope you enjoyed your recent tour! Share your experience and help others make informed decisions.',
      date: DateTime(2023, 5, 27),
      uid: '3',
    ),
    myNoti.Notification(
      title: 'Review',
      message: 'Exceptional tour experience! From the knowledgeable guide to the...',
      date: DateTime(2023, 5, 23),
      uid: '4',
    ),
    myNoti.Notification(
      title: 'Verification Complete',
      message: 'Great news! Your identification and identification have been verified and are valid. You are now ready to start organising...',
      date: DateTime(2023, 2, 12),
      uid: '5',
    ),
  ];
  // END OF DUMMY NOT CREATION

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationListItem(notification: notifications[index]);
        },
      ),
    );
  }
}