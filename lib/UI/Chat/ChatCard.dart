import 'package:flutter/material.dart';
import 'package:weather/UI/Chat/ChatPage.dart';

class CardChat extends StatelessWidget {
  final String userId;
  final String expertId;
  final String lastMessage;
  final String conversationId;
  final String currentUserId;
  final String userAvatar;
  final String expertAvatar;
  final String userFullName;
  final String expertFullName;
  final bool unread;

  CardChat({
    required this.userId,
    required this.expertId,
    required this.lastMessage,
    required this.conversationId,
    required this.currentUserId,
    required this.userAvatar,
    required this.expertAvatar,
    required this.userFullName,
    required this.expertFullName,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {

    final isExpert = currentUserId == expertId;
    final avatar = isExpert ? userAvatar : expertAvatar;
    final fullName = isExpert ? userFullName : expertFullName;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
          child: avatar.isEmpty
              ? const Icon(Icons.person, size: 30, color: Colors.white)
              : null,
        ),
        title: Text(
          fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          lastMessage.isNotEmpty ? lastMessage : 'No messages yet.',
          style: TextStyle(
            fontWeight: unread ? FontWeight.bold : FontWeight.normal, // Làm in đậm nếu chưa đọc
            color: unread ? Colors.blueAccent : Colors.black54, // Làm nổi bật nếu chưa đọc
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                conversationId: conversationId,
                currentUserId: currentUserId,
              ),
            ),
          );
        },
      ),
    );
  }
}
