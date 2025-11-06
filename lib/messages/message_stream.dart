import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'message_bubble.dart';

class MessagesStream extends StatefulWidget {
  // en Stateful widget enopbygger sig selv, når der sker ændringer
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
    // Hvis en af dem er tom, gør den ingenting
    if (currentUserEmail == null || selectedUserEmail.isEmpty) return;

    // de to e-mailadresser bliver sorteres og sætter dem sammen
    final sortedParticipants = [currentUserEmail, selectedUserEmail]..sort();

    // en unik identifikation af chatten mellem de to brugere.
    final chatId = sortedParticipants.join('_');
    // Begge brugere bruger altid den samme chatsti fordi den er sorteret
    setState(() {
      _stream = widget.firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(); // læser data fra databasen
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

        final filteredMessages = snapshot.data!.docs;
        final messageBubbles =
            _buildMessageBubbles(filteredMessages, currentUserEmail);

        return ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: messageBubbles,
        );
      },
    );
  }
}

// en list af messsage-bubble classe
List<MessageBubble> _buildMessageBubbles(
    // snapshot.data!.docs og login bruger
    List<QueryDocumentSnapshot> docs,
    String currentUserEmail) {
  return docs.map((msg) {
    final messageData = msg.data() as Map<String, dynamic>;
    return MessageBubble(
      sender: messageData['sender'],
      text: messageData['text'],
      isMe: messageData['sender'] == currentUserEmail,
    );
  }).toList();
}
