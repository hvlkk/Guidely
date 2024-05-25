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
