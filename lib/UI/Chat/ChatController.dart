import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Gửi tin nhắn (có thể có cả ảnh)
  Future<void> sendMessage({
    required String conversationId,
    required String message,
    required String senderId,
    String? imageUrl, // Thêm tham số imageUrl cho hình ảnh
  }) async {
    if (message.trim().isEmpty && imageUrl == null) return; // Kiểm tra nếu cả tin nhắn và ảnh đều rỗng

    final timestamp = FieldValue.serverTimestamp();

    try {
      // Gửi tin nhắn (có thể có cả hình ảnh)
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'message': message,
        'senderId': senderId,
        'timestamp': timestamp,
        'unread': true,
        'imageUrl': imageUrl ?? '', // Lưu URL hình ảnh nếu có, nếu không thì là chuỗi rỗng
      });

      // Cập nhật tin nhắn cuối cùng của cuộc trò chuyện
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': message,
        'lastTimestamp': timestamp,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Lấy danh sách cuộc trò chuyện (dựa trên id của chuyên gia)
  Stream<QuerySnapshot> getConversations(String expertId) {
    return _firestore
        .collection('conversations')
        .where('expertId', isEqualTo: expertId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  // Tạo cuộc trò chuyện mới
  Future<void> createConversation({
    required String userId,
    required String expertId,
  }) async {
    final conversationId = '$userId-$expertId';

    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (docSnapshot.exists) {
        print('Conversation already exists!');
      } else {
        await _firestore.collection('conversations').doc(conversationId).set({
          'conversationId': conversationId,
          'userId': userId,
          'expertId': expertId,
          'lastMessage': '',
          'lastTimestamp': FieldValue.serverTimestamp(),
        });
        print('Conversation created successfully!');
      }
    } catch (e) {
      print('Error creating conversation: $e');
    }
  }

  // Lấy các tin nhắn của một cuộc trò chuyện
  Stream<QuerySnapshot> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Đánh dấu tất cả tin nhắn là đã đọc
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final messagesSnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      for (var messageDoc in messagesSnapshot.docs) {
        await messageDoc.reference.update({'unread': false});
      }

      print('All messages marked as read.');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
}
