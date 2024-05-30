import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:guidely/blocs/session/voice_chat_bloc.dart';
import 'package:guidely/models/enums/voice_chat_state.dart';
import 'package:guidely/services/business_layer/session_service.dart';

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
  VoiceChatState voiceChatState = VoiceChatState.connecting;

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
    _voiceChatBloc.listenToVoiceChatSession(widget.sessionId, (String state) {
      if (state == VoiceChatState.connected.toString()) {
        setState(() {
          widget.voiceChatState = VoiceChatState.connected;
        });
        return;
      }
    });
  }

  @override
  void dispose() {
    _voiceChatBloc.signaling.close();
    super.dispose();
  }

  // todo: here, when the voice chat session will begin, we will update the value on the database
  // we will setup a listener on the database to listen to the changes and update the UI accordingly
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
                    SessionService().updateSession(widget.sessionId,
                        {"voiceChatState": widget.voiceChatState.toString()});
                  } else {
                    _voiceChatBloc.joinRoom(
                        textEditingController.text.trim(), widget.sessionId);
                    setState(() {});
                  }
                },
                child: Text(widget.isTourGuide ? "Start room" : "Join room"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  if (widget.isTourGuide) {
                    setState(() {
                      widget.voiceChatState = VoiceChatState.ended;
                    });
                    _voiceChatBloc.hangUp(widget.sessionId, true,
                        deleteSession: true);
                    clean();
                    return;
                  }
                  _voiceChatBloc.hangUp(widget.sessionId, false);
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

  void clean() {
    textEditingController.clear();
  }
}
