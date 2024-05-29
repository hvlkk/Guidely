import 'package:guidely/screens/session/sections/voice_chat_section/signaling.dart';

class VoiceChatBloc {
  final Signaling signaling = Signaling();

  Future<String> createRoom(String sessionId) async {
    return signaling.createRoom(sessionId);
  }

  Future<void> joinRoom(String roomId, String sessionId) async {
    signaling.joinRoom(sessionId, roomId);
  }

  void hangUp() {
    signaling.hangUp();
  }

  void openUserMedia() {
    signaling.openUserMedia();
  }

  void toggleMute() {
    signaling.toggleMute();
  }
}
