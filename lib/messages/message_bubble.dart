import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.sender,
      this.text,
      required this.isMe,
      required this.messageId,
      required this.chatId});

  final String? sender;
  final String? text;
  final bool isMe;
  final String messageId;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Hvis beskeden tilhører brugeren aktiveres long press
      onLongPress: isMe
          ? () async {
              // Når long press er aktiveret, vises der et showDialog-vindue
              bool? confirmed = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Delete message?"),
                  content:
                      Text("Are you sure you want to delete this message?"),
                  actions: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text("Delete"),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );
              // Når Delete trykkes, lukkes dialogen og true returneres
              if (confirmed == true) {
                await FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .doc(messageId)
                    .delete();
              }
            }
          // Hvis isMe = false, er long press slået fra
          : null,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              sender!,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
              ),
            ),
            Material(
              borderRadius: isMe //en spids i højre side, andre venstre!
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
              elevation: 5.0,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text!,
                  style: TextStyle(
                    // login ser hvid tekst og andre i sort farve!
                    color: isMe ? Colors.white : Colors.black54,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
