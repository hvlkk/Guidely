import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guidely/models/entities/notification.dart' as myNoti;

class NotificationListItem extends StatefulWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
  });

  final myNoti.Notification notification;

  @override
  _NotificationListItemState createState() => _NotificationListItemState();
}

class _NotificationListItemState extends State<NotificationListItem> {
  late bool isRead;

  @override
  void initState() {
    super.initState();
    isRead = widget.notification.isRead;
  }

  void _markAsRead() async {
    setState(() {
      isRead = true;
    });

     try {
        print("Marking as read");
        print(widget.notification.uid);
        final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.notification.uid);
        print(userDoc);
        final snapshot = await userDoc.get();
        print(snapshot.data());
        final notifications = List<Map<String, dynamic>>.from(snapshot.data()?['notifications'] ?? []);
        print("Notifications: ");
        print(notifications);

        for (var noti in notifications) {
          if (noti['date'] == widget.notification.date) {
            noti['isRead'] = true;
            break;
          }
        }

        await userDoc.update({'notifications': notifications});
      } catch (e) {
        print("Failed to update notification: $e");
      }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _markAsRead();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(widget.notification.title),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.notification.message),
                        const SizedBox(height: 8),
                        Text(
                          widget.notification.date.toString(),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              leading: const CircleAvatar(
                child: Icon(Icons.notifications),
              ),
              title: Text(
                widget.notification.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.notification.message,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.notification.date.toString(),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          ),
          if (!isRead)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
