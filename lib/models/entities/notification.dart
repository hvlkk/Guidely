import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';

class Notification {
  Notification({
    required this.title,
    required this.message,
    required this.date,
    required this.uid,
    this.isRead = false,
  });

  final String title;
  final String message;
  final String date;
  final String uid;
  bool isRead;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'date': date,
      'uid': uid,
      'isRead': isRead,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    String dateTime = map['date'].toString();

    return Notification(
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      date: dateTime,
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => toMap();
}

void showNotificationDialog(BuildContext context, Notification notification) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          notification.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  CommonUtils.formatDate(notification.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
