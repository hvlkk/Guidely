import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/models/entities/session.dart';
import 'package:guidely/models/entities/tour.dart';
import 'package:guidely/repositories/session_repository.dart';

class SessionService {
  // create session operation
  static Future<String> createSession(Tour tour) async {
    String sessionId = tour.sessionId;
    // call repository to create session
    Session session = Session(
      sessionId: sessionId,
      tourId: tour.uid,
      participants: [],
      mediaUrls: [],
      chatMessages: [],
    );
    SessionRepository().createSession(session);

    return sessionId;
  }

  // get session operation
  static Stream<DocumentSnapshot> getSession(String sessionId) {
    // call repository to get session
    return SessionRepository().getSessionStream(sessionId);
  }

  // update session operation
  Future<void> updateSession(
      String sessionId, Map<String, dynamic> data) async {
    return SessionRepository().updateSession(sessionId, data);
  }

  // delete session operation
  Future<void> deleteSession(String sessionId) async {
    // call repository to delete session
  }
}
