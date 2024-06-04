import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/models/entities/user.dart';

enum SessionStatus {
  cancelled,
  active,
  completed,
  inQuiz,
}

class Session {
  final String sessionId;
  final String tourId;
  final List<User>
      participants; // List of participants at the session != registered users
  final List<String>
      mediaUrls; // List of media files (images) at are associated with the session // save to storage
  final List<String> chatMessages;

  SessionStatus status = SessionStatus.active;
  bool voiceChatEnabled = false;

  Session({
    required this.sessionId,
    required this.tourId,
    required this.participants,
    required this.mediaUrls,
    required this.chatMessages,
    this.status = SessionStatus.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'tourId': tourId,
      'participants': participants.map((e) => e.toMap()).toList(),
      'mediaUrls': mediaUrls,
      'chatMessages': chatMessages,
      'status': status.toString(),
      'voiceChatEnabled': voiceChatEnabled,
    };
  }

  static fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return Session(
      sessionId: doc['sessionId'],
      tourId: doc['tourId'],
      participants:
          (doc['participants'] as List).map((e) => User.fromMap(e)).toList(),
      mediaUrls: doc['mediaUrls'],
      chatMessages: doc['chatMessages'],
    );
  }

  static Session fromMap(Map<String, dynamic> sessionData) {
    return Session(
      sessionId: sessionData['sessionId'],
      tourId: sessionData['tourId'],
      participants: (sessionData['participants'] as List)
          .map((e) => User.fromMap(e))
          .toList(),
      mediaUrls: List<String>.from(sessionData['mediaUrls']),
      chatMessages: List<String>.from(sessionData['chatMessages']),
      status: SessionStatus.values
          .firstWhere((e) => e.toString() == sessionData['status']),
    );
  }
}
