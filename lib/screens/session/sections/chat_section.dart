import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guidely/models/entities/user.dart';
import 'package:guidely/providers/user_data_provider.dart';
import 'package:guidely/repositories/session_repository.dart';
import 'package:uuid/uuid.dart';

class ChatSection extends ConsumerStatefulWidget {
  final Stream<List<Map<String, dynamic>>> chatMessagesStream;
  final String sessionId;

  const ChatSection({
    super.key,
    required this.chatMessagesStream,
    required this.sessionId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatSectionState();
}

class _ChatSectionState extends ConsumerState<ChatSection> {
  late chat_types.User _chatUser;
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final currentUser = ref.read(userDataProvider);
    currentUser.whenData((userData) {
      _setChatUser(userData);
    });
  }

  void _setChatUser(User userData) {
    _chatUser = chat_types.User(
      id: userData.uid,
      lastName: userData.username,
      imageUrl: userData.imageUrl,
    );
  }

  void _sendMessage(chat_types.PartialText message) {
    final textMessage = chat_types.TextMessage(
      author: _chatUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: uuid.v4(),
      text: message.text,
    );

    SessionRepository().updateSession(widget.sessionId, {
      'chatMessages': FieldValue.arrayUnion([textMessage.toJson()]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget.chatMessagesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final List<Map<String, dynamic>> messageJsons = snapshot.data!;
        final List<chat_types.Message> messages = messageJsons
            .map((messageJson) => chat_types.Message.fromJson(messageJson))
            .toList()
            .reversed
            .toList();

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Chat(
            messages: messages,
            onSendPressed: _sendMessage,
            user: _chatUser,
            showUserAvatars: true,
            showUserNames: true,
          ),
        );
      },
    );
  }
}
