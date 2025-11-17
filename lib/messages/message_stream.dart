import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'message_bubble.dart';

class MessagesStream extends StatefulWidget {
  // en Stateful widget enopbygger sig selv, når der sker ændringer
  final FirebaseFirestore firestore;
  final String? selectedUserEmail;
  final String? groupId;

  const MessagesStream({
    Key? key,
    required this.firestore,
    this.selectedUserEmail,
    this.groupId,
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
    if (oldWidget.selectedUserEmail != widget.selectedUserEmail ||
        oldWidget.groupId != widget.groupId) {
      _createStream(); // lave en ny stream når selectet bruger ændres
    }
  } //MessagesStream gør at beskeren bliver updateret live-mode

  void _createStream() {
    final currentUserEmail = loggedInUser?.email;

    // Hvis en af dem er tom, gør den ingenting
    if (currentUserEmail == null) return;
    if (widget.groupId != null) {
      setState(() {
        _stream = widget.firestore
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots();
      });
      return;
    }
    final selectedUserEmail = widget.selectedUserEmail;
    if (selectedUserEmail == null || selectedUserEmail.isEmpty) return;

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
          .snapshots(); //snapshots() Opretter en live stream fra Firestore
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = loggedInUser?.email;
    if (currentUserEmail == null || _stream == null) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      //Lytter til snapshots-stream hele tiden
      stream: _stream,
      builder: (context, snapshot) {
        // Opbygger UI hver gang data ændres
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        // ingen setState, fordi StreamBuilder automatisk opdaterer UI'et

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No messages yet'));
        }

        final messageList = _buildMessageBubbles(
          snapshot.data!.docs,
          currentUserEmail,
        );

        return ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: messageList,
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
      messageId: msg.id,
      chatId: msg.reference.parent.parent!.id,
    );
  }).toList();
}
