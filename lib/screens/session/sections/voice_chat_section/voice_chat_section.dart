import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:guidely/blocs/session/voice_chat_bloc.dart';

enum VoiceChatState {
  idle,
  connecting,
  connected,
}

class VoiceChatSection extends StatefulWidget {
  VoiceChatSection({
    super.key,
    required this.sessionId,
    required this.isTourGuide,
    required this.hostIconURL,
  });

  final bool isTourGuide;
  final String hostIconURL;
  final String sessionId;
  VoiceChatState voiceChatState = VoiceChatState.idle;

  @override
  _VoiceChatSectionState createState() => _VoiceChatSectionState();
}

class _VoiceChatSectionState extends State<VoiceChatSection> {
  late final VoiceChatBloc _voiceChatBloc;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _voiceChatBloc = VoiceChatBloc();
    _voiceChatBloc.signaling.onAddRemoteStream = (MediaStream stream) {
      setState(() {});
    };
  }

  @override
  void dispose() {
    _voiceChatBloc.signaling.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: widget.isTourGuide &&
                      widget.voiceChatState == VoiceChatState.connected
                  ? Center(
                      child: ClipOval(
                        child: Image.network(
                          widget.hostIconURL,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : widget.isTourGuide
                      ? const Text("Create a room to start the voice chat")
                      : const Text(
                          "Waiting for the host to start the voice chat"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (widget.isTourGuide) {
                    final roomId =
                        await _voiceChatBloc.createRoom(widget.sessionId);
                    textEditingController.text = roomId;
                    setState(() {
                      widget.voiceChatState = VoiceChatState.connected;
                    });
                  } else {
                    _voiceChatBloc.joinRoom(
                        textEditingController.text.trim(), widget.sessionId);
                  }
                },
                child: Text(widget.isTourGuide ? "Start room" : "Join room"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  _voiceChatBloc.hangUp();
                },
                child: const Text(
                  "End Voice Chat",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _voiceChatBloc.openUserMedia();
                },
                child: const Text("Toggle Mic"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _voiceChatBloc.toggleMute();
                },
                child: const Text("Mute/Unmute"),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
