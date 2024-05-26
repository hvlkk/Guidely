import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/models/entities/session.dart';

class SessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateSession(Session session) async {
    await _firestore.collection('sessions').doc(session.sessionId).set(
          session.toMap(),
          SetOptions(merge: true),
        );
  }

  Stream<DocumentSnapshot> getSessionStream(String sessionId) {
    return _firestore.collection('sessions').doc(sessionId).snapshots();
  }

  Stream<List<Session>> getSessionsStream() {
    return _firestore.collection('sessions').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Session.fromFirestore(doc)).toList() as List<Session>,
        );
  }
}
