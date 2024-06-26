import 'package:flutter/material.dart';
import 'package:guidely/models/entities/notification.dart' as myNoti;
import 'package:guidely/screens/util/notifications.dart';

class CustomNotificationIcon extends StatelessWidget {
  final List<myNoti.Notification> notifications;

  const CustomNotificationIcon({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    notifications.sort((a, b) => b.date.compareTo(a.date));

    final newestNotifications = notifications.take(10).toList();

    final unreadCount = (newestNotifications
            .where((notification) => !notification.isRead)
            .toList())
        .length;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => NotificationsScreen(
              notifications: notifications,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          const Icon(Icons.notifications,
              size: 30), // Customize the icon size as needed
          if (unreadCount > 0) ...[
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red, // Red color for the notification badge
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
