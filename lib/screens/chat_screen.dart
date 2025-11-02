import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../messages/message_stream.dart';

// forbindelsen til databasen,
// opretter en instans af Firestore, så vi kan gemme og læse data
final _firestore = FirebaseFirestore.instance;
// gemmer oplysninger om den indloggede bruger
// ? betyder, at værdien kan være null
User? loggedInUser;
// En controller til TextField til at læse eller rydde den indtastede tekst
final messageTextController = TextEditingController();

class ChatScreen extends StatefulWidget {
  // static const String id bruges til at identificere siden i navigationen
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
// En variabel til at gemme beskedteksten, inden den sendes
  late String messageText;

  @override
  void initState() {
    super.initState();

    // at identificere den indloggede bruger

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print('Logged in as: ${loggedInUser!.email}');
      } else {
        print('No user signed in.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // scaffold builder siden og har to dele en app-bar og en body
      appBar: AppBar(
        // betyder at den venstre side skal ikke have knappen
        leading: null,
        actions: <Widget>[
          IconButton(
              // at logge brugeren ud og gå tilbage til den forrige side
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      // Sikrer, at indholdet vises i de sikre områder af skærmen
      body: SafeArea(
        // Column arrangerer indholdet lodret
        child: Column(
          // giver afstand mellem beskederne
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // den består af en del til at vise beskeder og en send afdeling
          children: <Widget>[
            MessagesStream(
              firestore: _firestore,
            ),
            Container(
              // den container for at sende-besked indeholder row:
              // en tekst-file og en knappe
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      // onChanged gemmer værdien i messageText hver gang teksten ændres
                      onChanged: (value) {
                        messageText = value;
                      }, // når brugeren indtaster Enter, Parameteren text
                      //  får automatisk værdien, som brugeren har skrevet i
                      // TextField,
                      onSubmitted: sendMessage,
                      // ændrer kun udseendet af Enter-knappen på tastaturet
                      textInputAction: TextInputAction.send,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      sendMessage(messageText);
                    },
                    child: Text(
                      'Send',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void sendMessage(String text) {
  if (text.trim().isEmpty) return; // Hvis teksten er tom, sendes ikke noget
  _firestore.collection('messages').add({
    'text': text,
    'sender': loggedInUser?.email,
    'timestamp': FieldValue.serverTimestamp(),
  });

  messageTextController.clear(); // Text-filden bliver ryddes
}
