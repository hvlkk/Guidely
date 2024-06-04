import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

class Signaling {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
      {
        'urls': 'turn:turn.anyfirewall.com:443?transport=tcp',
        'username': 'webrtc',
        'credential': 'webrtc'
      }
    ]
  };

  // Peer connection and stream variables
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  Future<void> openUserMedia() async {
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });
  }

  void close() {
    hangUp();
  }

  // Creates a new room for the given session ID.
  Future<String> createRoom(String sessionId) async {
    DocumentReference roomRef;
    try {
      DocumentReference sessionRef =
          _firestore.collection('sessions').doc(sessionId);
      roomRef = sessionRef.collection('rooms').doc();
    } catch (e) {
      print("Error, failed to create room because of $e\n");
      rethrow;
    }

    peerConnection = await createPeerConnection(configuration);
    _registerPeerConnectionListeners();

    // Add local tracks to the peer connection
    localStream?.getTracks().forEach((track) {
      peerConnection!.addTrack(track, localStream!);
    });

    CollectionReference<Map<String, dynamic>> callerCandidatesCollection;

    try {
      callerCandidatesCollection = roomRef.collection('callerCandidates');
    } catch (e) {
      print(
          "Error, failed to create callerCandidatesCollection because of $e\n");
      rethrow;
    }

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        print("Sending ICE candidate: ${candidate.candidate}");
        callerCandidatesCollection.add(candidate.toMap());
      } else {
        print("ICE candidate is null");
      }
    };

    // creates an offer and set local description
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print("created offer: ${offer.sdp}");

    // storing the offer in the room document
    // var roomWithOffer = {'offer': offer.toMap()};
    Map<String, dynamic> roomWithOffer = {
      'offer': {'type': offer.type}
    };
    await roomRef.set(roomWithOffer);
    var roomId = roomRef.id;

    // Set up handling of remote tracks
    peerConnection?.onTrack = (RTCTrackEvent event) {
      print("Got remote track: ${event.streams[0]}");
      event.streams[0].getTracks().forEach((track) {
        remoteStream?.addTrack(track);
      });
    };

    // listens for changes in the room document
    roomRef.snapshots().listen((event) async {
      Map<String, dynamic> data = event.data() as Map<String, dynamic>;

      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        RTCSessionDescription answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        print("Someone tried to connect");
        await peerConnection!.setRemoteDescription(answer);
      }
    });

    // listens for ICE candidates from the callee
    roomRef.collection('calleeCandidates').snapshots().listen((event) {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          print("Got new ICE candidate from callee: ${data['candidate']}");
          RTCIceCandidate candidate = RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
          print("Adding ICE candidate from callee: ${candidate.candidate}");
          peerConnection!.addCandidate(candidate);
        }
      }
    });

    return roomId;
  }

  // joins an existing room with the given session ID and room ID.
  Future<void> joinRoom(String sessionId, String roomId) async {
    DocumentReference sessionRef =
        _firestore.collection('sessions').doc(sessionId);
    DocumentReference roomRef = sessionRef.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      peerConnection = await createPeerConnection(configuration);
      _registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      var calleeCandidatesCollection;

      try {
        calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      } catch (e) {
        print(
            "Error, failed to create calleeCandidatesCollection because of $e\n");
        rethrow;
      }

      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        print("Sending ICE candidate: ${candidate}");
        calleeCandidatesCollection.add(candidate.toMap());
      };

      peerConnection!.onTrack = (RTCTrackEvent event) {
        event.streams[0].getTracks().forEach((track) {
          remoteStream?.addTrack(track);
        });
      };

      var data = roomSnapshot.data() as Map<String, dynamic>;
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      var answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);

      // updates the room document with the answer
      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };
      await roomRef.update(roomWithAnswer);
    }

    // listens for changes in the room document
    roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((document) {
        var data = document.doc.data() as Map<String, dynamic>;
        var candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        );
        print("Adding ICE candidate from caller: ${candidate.candidate}");
        peerConnection!.addCandidate(candidate);
      });
    });
  }

  void hangUp() {
    localStream?.getTracks().forEach((track) {
      track.stop();
    });

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) {
        track.stop();
      });
    }

    peerConnection?.close();
    localStream?.dispose();
    remoteStream?.dispose();
  }

  void toggleMute() {
    localStream?.getAudioTracks().forEach((track) {
      track.enabled = !track.enabled;
    });
  }

  void _registerPeerConnectionListeners() {
    peerConnection!.onIceGatheringState = (state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection!.onConnectionState = (state) {
      print('Connection state change: $state');
    };

    peerConnection!.onIceConnectionState = (state) {
      print('ICE connection state change: $state');
    };

    peerConnection!.onSignalingState = (state) {
      print('Signaling state change: $state');
    };

    peerConnection!.onIceCandidate = (candidate) {
      print('ICE candidate: ${candidate.candidate}');
    };
  }
}
