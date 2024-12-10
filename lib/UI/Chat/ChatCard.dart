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
  final String messageType;
  final String? imageUrl;

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
    required this.messageType, // Nhận loại tin nhắn
    this.imageUrl, // Nhận URL hình ảnh
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem người dùng hiện tại là người dùng hay chuyên gia
    final isExpert = currentUserId == expertId;
    final avatar = isExpert ? userAvatar : expertAvatar;
    final fullName = isExpert ? userFullName : expertFullName;

    return Card(
      color: Colors.white,
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
        subtitle: messageType == 'image' && imageUrl != null// Kiểm tra loại tin nhắn
            ? GestureDetector(
          child: Image.network( // Hiển thị hình ảnh nếu loại tin nhắn là hình ảnh
            imageUrl!,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          onTap: () {
            // Tùy chọn để xem hình ảnh lớn hơn khi nhấn vào hình ảnh
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: Image.network(imageUrl!),
              ),
            );
          },
        )
            : Text(
          lastMessage.isNotEmpty ? lastMessage : 'No messages yet.',
          style: TextStyle(
            fontWeight: unread ? FontWeight.bold : FontWeight.normal,
            color: unread ? Colors.blueAccent : Colors.black54,
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
