import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'message_bubble.dart';

class MessagesStream extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String selectedUserEmail;

  const MessagesStream({
    Key? key,
    required this.firestore,
    required this.selectedUserEmail,
  }) : super(key: key);

  @override
  State<MessagesStream> createState() => _MessagesStreamState();
}

class _MessagesStreamState extends State<MessagesStream> {
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    _createStream();
  }

  @override
  void didUpdateWidget(MessagesStream oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedUserEmail != widget.selectedUserEmail) {
      _createStream(); // lave en ny stream når selectet bruger ændres
    }
  }

  void _createStream() {
    final currentUserEmail = loggedInUser?.email;
    final selectedUserEmail = widget.selectedUserEmail;

    if (currentUserEmail == null || selectedUserEmail.isEmpty) return;

    final sortedParticipants = [currentUserEmail, selectedUserEmail]..sort();
    final chatId = sortedParticipants.join('_');

    setState(() {
      _stream = widget.firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = loggedInUser?.email;
    if (currentUserEmail == null || _stream == null) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No messages yet'));
        }

        final messages = snapshot.data!.docs;
        final filteredMessages = messages;

        List<MessageBubble> messageBubbles = filteredMessages.map((message) {
          final messageData = message.data() as Map<String, dynamic>;
          return MessageBubble(
            sender: messageData['sender'],
            text: messageData['text'],
            isMe: messageData['sender'] == currentUserEmail,
          );
        }).toList();

        return ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: messageBubbles,
        );
      },
    );
  }
}
