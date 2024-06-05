import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/screens/session/sections/voice_chat_section/signaling.dart';
import 'package:guidely/services/business_layer/session_service.dart';

class VoiceChatBloc {
  final Signaling signaling = Signaling();

  // methods for the signaling
  Future<String> createRoom(String sessionId) async {
    return signaling.createRoom(sessionId);
  }

  Future<void> joinRoom(String roomId, String sessionId) async {
    print('joining room');
    print("room id: $roomId");
    print("session id: $sessionId");
    await signaling.joinRoom(sessionId, roomId);
  }

  void hangUp(String sessionId, String roomId, {bool deleteRoom = false}) {
    signaling.hangUp();

    if (deleteRoom) {
      SessionService().deleteSessionRoom(sessionId, roomId);
    }
  }

  void openUserMedia() {
    signaling.openUserMedia();
  }

  void toggleMute() {
    signaling.toggleMute();
  }

  // listener to the database
  void listenToVoiceChatSession(String sessionId, Function(String) callBack) {
    FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .snapshots()
        .listen((event) {
      if (event.data() != null) {
        final data = event.data()!;
        callBack(data['voiceChatState']);
      }
    });
  }
}
