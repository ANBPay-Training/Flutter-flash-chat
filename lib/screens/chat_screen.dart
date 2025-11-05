import 'package:flash_chat/screens/userList_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../messages/message_stream.dart';
import 'login_screen.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;
final messageTextController = TextEditingController();

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  final String? selectedUserEmail;

  ChatScreen({this.selectedUserEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late String messageText;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
        print('Logged in as: ${loggedInUser!.email}');
      } else {
        print('No user signed in.');
      }
    } catch (e) {
      print('⚠️ Error getting user: $e');
    } finally {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = loggedInUser?.email;

    if (currentUserEmail == null) {
      print('⏳ Waiting for loggedInUser...');
      return Center(child: CircularProgressIndicator());
    }
    if (_isLoadingUser) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      // en app bar og en body
      appBar: AppBar(
        leading: IconButton(
          // venstre default tilbage-knappen pyntes med:
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
              // at logUd-knap
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pushReplacementNamed(context, LoginScreen.id);
              }),
        ],
        title: Text('⚡️Chat with ${widget.selectedUserEmail}'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        // sikre områder af skærmen
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, //afstand mellem
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: _isLoadingUser || loggedInUser == null
                  ? Center(child: CircularProgressIndicator())
                  : MessagesStream(
                      key: ValueKey(widget.selectedUserEmail),
                      firestore: _firestore,
                      selectedUserEmail: widget.selectedUserEmail!,
                    ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      onSubmitted: (value) => // inter knappen
                          sendMessage(value, widget.selectedUserEmail!),
                      // ændrer kun udseendet af Enter-knappen på tastaturet
                      textInputAction: TextInputAction.send,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      sendMessage(messageText, widget.selectedUserEmail!);
                      setState(() {});
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

void sendMessage(String text, String receiverEmail) async {
  if (text.trim().isEmpty) return;
  if (loggedInUser == null) {
    print('⚠️ No logged-in user!');
    return;
  }

  final senderEmail = loggedInUser!.email!;
  final timestamp = FieldValue.serverTimestamp();

  final sortedParticipants = [senderEmail, receiverEmail]..sort();
  final chatId = sortedParticipants.join('_');

  try {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': text.trim(),
      'sender': senderEmail,
      'receiver': receiverEmail,
      'timestamp': timestamp,
    });

    print('💾 Message sent from $senderEmail to $receiverEmail');
  } catch (e) {
    print('❌ Error sending message: $e');
  }
  messageTextController.clear();
}
