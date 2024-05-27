// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:guidely/screens/session/sections/voice_chat_section/signaling.dart';

class VoiceChatSection extends StatefulWidget {
  const VoiceChatSection({super.key, required this.sessionId});

  final String sessionId;

  @override
  _VoiceChatSectionState createState() => _VoiceChatSectionState();
}

class _VoiceChatSectionState extends State<VoiceChatSection> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
