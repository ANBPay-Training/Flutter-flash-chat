import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageSend {
  final FirebaseFirestore firestore;
  final TextEditingController messageController;
  final User? loggedInUser;

  MessageSend({
    required this.firestore,
    required this.messageController,
    required this.loggedInUser,
  });

  Future<void> sendMessage(String text, String receiverEmail) async {
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
      await firestore
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

    messageController.clear();
  }

  void sendMessageToGroup(String text, String groupId) {
    final currentUserEmail = loggedInUser?.email;

    firestore.collection('groups').doc(groupId).collection('messages').add({
      'text': text,
      'sender': currentUserEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });

    messageController.clear();
  }
}
