import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  Notification({
    required this.title,
    required this.message,
    required this.date,
    required this.uid,
  });

  final String title;
  final String message;
  final String date;
  final String uid;
  // final String senderUid;
  bool isRead = false;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'date': date,
      'uid': uid,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp = map['date'] ?? Timestamp(0, 0);
    DateTime dateTime = timestamp.toDate();

    return Notification(
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      date: dateTime.toString(),
    );
  }
}
