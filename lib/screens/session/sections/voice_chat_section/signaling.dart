import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  Future<String> createRoom() {
    // method implementation
    return Future.value('');
  }

  Future<void> joinRoom(String sessionId, RTCVideoRenderer remoteVideo) async {
    // method implementation
  }

  void registerPeerConnectionListeners() {
    // method implementation
  }
}
