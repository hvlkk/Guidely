import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/misc/common.dart';
import 'package:guidely/models/entities/notification.dart' as myNoti;
import 'package:guidely/models/entities/notification.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/services/business_layer/user_service.dart';

class NotificationListItem extends ConsumerStatefulWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
  });

  final myNoti.Notification notification;

  @override
  _NotificationListItemState createState() => _NotificationListItemState();
}

class _NotificationListItemState extends ConsumerState<NotificationListItem> {
  late bool isRead;

  @override
  void initState() {
    super.initState();
    isRead = widget.notification.isRead;
  }

  void _markAsRead(
      String userId, List<myNoti.Notification> userNotifications) async {
    setState(() {
      isRead = true;
    });

    List serializedNotifications =
        userNotifications.map((notif) => notif.toJson()).toList();

    for (var notif in serializedNotifications) {
      if (notif['uid'] == widget.notification.uid) {
        notif['isRead'] = true;
        break;
      }
    }
    UserService.updateData(
      context,
      userId,
      {'notifications': serializedNotifications},
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(userDataProvider);

    return userDataAsync.when(
      data: (userData) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _markAsRead(userData.uid, userData.notifications);
                  showNotificationDialog(context, widget.notification);
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
                        CommonUtils.formatDate(widget.notification.date),
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        print("Error: $error");
        return const Center(child: Text("Error loading data"));
      },
    );
  }
}
