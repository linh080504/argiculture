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

            // Fetch both user and expert data in parallel
            return FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserAndExpertData(userId, currentUserId),
              builder: (context, userExpertSnapshot) {
                if (userExpertSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userExpertSnapshot.hasError) {
                  return Center(child: Text('Error: ${userExpertSnapshot.error}'));
                }

                if (!userExpertSnapshot.hasData) {
                  return Center(child: Text('Data not found.'));
                }

                final userData = userExpertSnapshot.data!['user'];
                final expertData = userExpertSnapshot.data!['expert'];

                final userFullName = userData['fullname'] ?? 'User';
                final userAvatar = userData['profilePicture'] ?? 'default_user_avatar_url';  // Use default if null
                final expertFullName = expertData['fullname'] ?? 'Expert';
                final expertAvatar = expertData['profilePicture'] ?? 'default_expert_avatar_url';  // Use default if null

                final conversationData = conversation.data() as Map<String, dynamic>?;

                final unread = conversationData?.containsKey('unread') == true
                    ? conversationData!['unread'] ?? false
                    : false;

                final imageUrl = conversationData?.containsKey('imageUrl') == true
                    ? conversationData!['imageUrl']
                    : '';

                final messageType = conversationData?.containsKey('messageType') == true
                    ? conversationData!['messageType']
                    : 'text';

                return CardChat(
                  userId: userId, // ID người dùng
                  expertId: conversation['expertId'],
                  currentUserId: currentUserId,
                  lastMessage: lastMessage,
                  conversationId: conversationId,
                  userAvatar: userAvatar,
                  expertAvatar: expertAvatar,
                  userFullName: userFullName,
                  expertFullName: expertFullName,
                  unread: unread,
                  messageType: messageType,
                  imageUrl: imageUrl,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchUserAndExpertData(String userId, String expertId) async {
    try {
      // Fetch user and expert data in parallel
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId).get();
      final expertDoc = FirebaseFirestore.instance.collection('users').doc(expertId).get();

      final userSnapshot = await userDoc;
      final expertSnapshot = await expertDoc;

      if (userSnapshot.exists && expertSnapshot.exists) {
        return {
          'user': userSnapshot.data() as Map<String, dynamic>,
          'expert': expertSnapshot.data() as Map<String, dynamic>,
        };
      } else {
        throw Exception('User or expert data not found');
      }
    } catch (e) {
      throw Exception('Error fetching user and expert data: $e');
    }
  }
}
