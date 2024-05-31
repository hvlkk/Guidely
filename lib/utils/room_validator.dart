import 'package:cloud_firestore/cloud_firestore.dart';

class RoomValidator {
  static Future<bool> isValidRoomId(String sessionId, String roomId) {
    // get the room from the database
    CollectionReference sessionRef = FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .collection('rooms');

    return sessionRef.doc(roomId).get().then((value) => value.exists);
  }
}
