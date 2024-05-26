import 'package:flutter/material.dart';

class ChatSection extends StatelessWidget {
  final Stream<List<String>> chatMessagesStream;

  const ChatSection({super.key, required this.chatMessagesStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: chatMessagesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        final List<String> chatMessages = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(child: Text('P')),
                  title: Text('Participant: ${chatMessages[index]}'),
                  subtitle: Text('11:31 AM'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
