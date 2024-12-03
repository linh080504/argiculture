import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather/UI/Chat/ChatCard.dart'; // Import CardChat widget

class ExpertChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.email!; // Get current user's email

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .where('expertId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No conversations yet.'));
        }

        final conversations = snapshot.data!.docs
            .where((doc) => doc['lastTimestamp'] != null)
            .toList();

        conversations.sort((a, b) => b['lastTimestamp'].compareTo(a['lastTimestamp']));

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            final userId = conversation['userId'];
            final lastMessage = conversation['lastMessage'];
            final conversationId = conversation['conversationId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Center(child: Text('User not found.'));
                }

                final userFullName = userSnapshot.data!['fullname'] ?? 'User';

                final userAvatar = userSnapshot.data!['profilePicture'] ?? '';

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
                  builder: (context, expertSnapshot) {
                    if (expertSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (expertSnapshot.hasError) {
                      return Center(child: Text('Error: ${expertSnapshot.error}'));
                    }

                    if (!expertSnapshot.hasData || !expertSnapshot.data!.exists) {
                      return Center(child: Text('Không tìm ra thông tin chuyên gia.'));
                    }

                    final expertAvatar = expertSnapshot.data!['profilePicture'] ?? '';
                    final expertFullName = expertSnapshot.data!['fullname'] ?? 'Expert';

                    final conversationData = conversation.data() as Map<String, dynamic>?;
                    final unread = conversationData?.containsKey('unread') == true
                        ? conversationData!['unread'] ?? false  // Default to false if 'unread' doesn't exist
                        : false;  // Default to false if conversationData is null or 'unread' is not found

                     return CardChat(
                      userId: userId,
                      expertId: currentUserId,
                      currentUserId: currentUserId,
                      lastMessage: lastMessage,
                      conversationId: conversationId,
                      userAvatar: userAvatar,
                      expertAvatar: expertAvatar,
                      userFullName: userFullName,
                      expertFullName: expertFullName,
                      unread: unread,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
