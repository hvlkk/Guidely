class Notification {
  Notification({
    required this.title,
    required this.message,
    required this.date,
    required this.uid,
  });

  final String title;
  final String message;
  final DateTime date;
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
    return Notification(
      title: map['title'],
      message: map['message'],
      date: map['date'].toDate(),
      uid: map['uid'],
    );
  }
}