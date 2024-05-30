import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guidely/models/enums/voice_chat_state.dart';
import 'package:guidely/screens/session/sections/voice_chat_section/signaling.dart';
import 'package:guidely/services/business_layer/session_service.dart';

class VoiceChatBloc {
  final Signaling signaling = Signaling();

  // methods for the signaling
  Future<String> createRoom(String sessionId) async {
    return signaling.createRoom(sessionId);
  }

  Future<void> joinRoom(String roomId, String sessionId) async {
    signaling.joinRoom(sessionId, roomId);
  }

  void hangUp(String sessionId, bool bool, {bool deleteSession = false}) {
    signaling.hangUp();

    if (deleteSession) {
      SessionService().deleteSession(sessionId);
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
      print("I am listening to the voice chat session");
      if (event.data() != null) {
        print("I received some data from the voice chat session");
        final data = event.data()!;
        print("i am about to call the callback");
        callBack(data['voiceChatState']);
      }
    });
  }
}
