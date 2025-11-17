import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'create_gruop_screen.dart';
import 'login_screen.dart';

class UserListScreen extends StatelessWidget {
  static const String id = 'user_screen';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateGroupScreen()),
              );
            },
          ),
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pushReplacementNamed(context, LoginScreen.id);
              }),
        ],
        title: Text('Users & Groups'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((user) {
                  return user['email'] != _auth.currentUser?.email;
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userEmail = user['email'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 20.0),
                        ),
                        onPressed: () {
                          print('Selected user: $userEmail');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(selectedUserEmail: userEmail),
                            ),
                          );
                        },
                        child: Text(
                          userEmail,
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(thickness: 2, color: Colors.grey),

          // 🔹 لیست گروه‌ها
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final groups = snapshot.data!.docs;

                return ListView(
                  padding: EdgeInsets.all(16),
                  children: groups.map((group) {
                    final groupName = group['name'] ?? 'Unnamed Group';
                    final groupId = group.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 20.0),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                groupId: groupId,
                                groupName: groupName,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Group: $groupName",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
