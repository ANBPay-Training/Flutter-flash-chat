import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart'; // viser beskeder som "boble"-stil

class MessagesStream extends StatelessWidget {
  final FirebaseFirestore firestore;
  MessagesStream({required this.firestore});

  @override
  Widget build(BuildContext context) {
    // lytter til en stream og builder UI'et, hver gang data ændres
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('messages')
          // Sorterer beskederne efter tid, med de nyeste først
          .orderBy('timestamp', descending: true)
          // indeholder den aktuelle tilstand af streamen
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            // Hvis der endnu ikke er nogen data vises en spinner
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        // list af alle documents
        final messages = snapshot.data!.docs;
        // en tom list til at samle alle boble-wigets
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          // retunere alle dokumenter som map
          final messageData = message.data() as Map<String, dynamic>;
          final messageText = messageData['text'];
          final messageSender = messageData['sender'];
          // defineret i chat_screen og gemmer den aktuelt loggede bruger
          final currentUser = loggedInUser?.email;

          // opretter en message-bubble med de tre variabler
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );
          // adder hver message-bubble objekt til en liste som retunere senere
          messageBubbles.add(messageBubble);
        }
        // fylder den resterende plads på skærmen
        return Expanded(
          // retuner aller besked som bubbler
          child: ListView(
            // de nyeste beskeder vises øverst på listen
            reverse: true,
            // afstand fra kanterne
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}
