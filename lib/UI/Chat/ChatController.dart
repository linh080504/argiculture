import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String conversationId,
    required String message,
    required String senderId,
  }) async {
    if (message.trim().isEmpty) return;

    final timestamp = FieldValue.serverTimestamp();

    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'message': message,
        'senderId': senderId,
        'timestamp': timestamp,
        'unread': true,
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': message,
        'lastTimestamp': timestamp,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Stream<QuerySnapshot> getConversations(String expertId) {
    return _firestore
        .collection('conversations')
        .where('expertId', isEqualTo: expertId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

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

  Stream<QuerySnapshot> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

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
