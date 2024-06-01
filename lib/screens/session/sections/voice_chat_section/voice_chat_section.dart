import 'package:flutter/material.dart';
import 'package:guidely/blocs/session/voice_chat_bloc.dart';
import 'package:guidely/models/enums/voice_chat_state.dart';
import 'package:guidely/services/business_layer/session_service.dart';
import 'package:guidely/utils/room_validator.dart';

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

  bool hasJoined = false;
  late String roomId;

  @override
  void initState() {
    super.initState();
    _voiceChatBloc = VoiceChatBloc();

    _voiceChatBloc.listenToVoiceChatSession(widget.sessionId, (String state) {
      if (state == VoiceChatState.connected.toString()) {
        setState(() {
          widget.voiceChatState = VoiceChatState.connected;
        });
        return;
      }
      if (state == VoiceChatState.ended.toString()) {
        setState(() {
          widget.voiceChatState = VoiceChatState.ended;
        });
        clean();
      }
    });
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
              child:
                  hasJoined && widget.voiceChatState == VoiceChatState.connected
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
                onPressed: widget.isTourGuide ? _startRoom : _joinRoom,
                child: Text(widget.isTourGuide ? "Start room" : "Join room"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _endVoiceChat,
                child: const Text(
                  "End Voice Chat",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: _toggleMic,
                child: const Text("Toggle Mic"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _toggleMute,
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

  Future<void> _startRoom() async {
    final roomIdGenerated = await _voiceChatBloc.createRoom(widget.sessionId);
    textEditingController.text = roomIdGenerated;
    setState(() {
      hasJoined = true;
      roomId = roomIdGenerated;
      widget.voiceChatState = VoiceChatState.connected;
    });
    SessionService().updateSession(
        widget.sessionId, {"voiceChatState": widget.voiceChatState.toString()});
  }

  Future<void> _joinRoom() async {
    final usersInput = textEditingController.text.trim();
    bool isValid =
        await RoomValidator.isValidRoomId(widget.sessionId, usersInput);

    if (!isValid) {
      return;
    }
    _voiceChatBloc.joinRoom(usersInput, widget.sessionId);
    setState(() {
      hasJoined = true;
    });
  }

  void _endVoiceChat() {
    setState(() {
      hasJoined = false;
    });
    if (widget.isTourGuide) {
      setState(() {
        widget.voiceChatState = VoiceChatState.ended;
      });
      SessionService().updateSession(widget.sessionId,
          {"voiceChatState": widget.voiceChatState.toString()});
    }
    _voiceChatBloc.hangUp(widget.sessionId, roomId,
        deleteRoom: widget.isTourGuide);
    clean();
  }

  void _toggleMic() {
    _voiceChatBloc.openUserMedia();
  }

  void _toggleMute() {
    _voiceChatBloc.toggleMute();
  }

  void clean() {
    textEditingController.clear();
  }
}
