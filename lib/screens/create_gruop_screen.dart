import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> selectedUsers = [];
  final TextEditingController groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          TextButton(
            onPressed:
                selectedUsers.length < 2 || groupNameController.text.isEmpty
                    ? null
                    : () async {
                        final groupId =
                            DateTime.now().millisecondsSinceEpoch.toString();

                        await _firestore.collection('groups').doc(groupId).set({
                          'name': groupNameController.text.trim(),
                          'members': selectedUsers,
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              groupId: groupId,
                              groupName: groupNameController.text.trim(),
                            ),
                          ),
                        );
                      },
            child: Text(
              "Create",
              style: TextStyle(
                color:
                    selectedUsers.length < 2 || groupNameController.text.isEmpty
                        ? Colors.grey
                        : Colors.white,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final users = snapshot.data!.docs;

                return ListView(
                  children: users.map((user) {
                    final email = user['email'];
                    final isSelected = selectedUsers.contains(email);

                    return ListTile(
                      title: Text(email),
                      trailing: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedUsers.remove(email);
                          } else {
                            selectedUsers.add(email);
                          }
                        });
                      },
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
