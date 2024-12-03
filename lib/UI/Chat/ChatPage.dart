import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather/UI/Chat/ChatController.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String currentUserId;

  ChatPage({
    required this.conversationId,
    required this.currentUserId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatController _chatController = ChatController();
  final ScrollController _scrollController = ScrollController();

  String? chatPartnerName;
  String? chatPartnerProfilePicture;
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _loadChatPartnerInfo();
  }
  Future<void> _loadChatPartnerInfo() async {
    List<String> emails = widget.conversationId.split('-');
    String chatPartnerEmail = emails.firstWhere(
          (email) => email != widget.currentUserId,
    );

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(chatPartnerEmail)
        .get();

    if (userDoc.exists) {
      setState(() {
        chatPartnerName = userDoc['fullname'] ?? 'Người dùng';
        chatPartnerProfilePicture = userDoc['profilePicture'] ?? '';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: chatPartnerProfilePicture != null
                  ? NetworkImage(chatPartnerProfilePicture!)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            SizedBox(width: 10),
            Text(chatPartnerName ?? 'Đang tải...'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message['senderId'] == widget.currentUserId; // Kiểm tra tin nhắn của người dùng hiện tại

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Card(
                          color: isCurrentUser ? Colors.blue[500] : Colors.white10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              message['message'],
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Aa',
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      fillColor: Colors.deepPurple[300],
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2), // Màu viền khi chưa focus
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2), // Màu viền khi focus
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: Colors.deepPurple[300],
                    size: 40,
                  ),
                  onPressed: () async {
                    if (_messageController.text.trim().isNotEmpty) {
                      await _chatController.sendMessage(
                        conversationId: widget.conversationId,
                        message: _messageController.text,
                        senderId: widget.currentUserId,
                      );
                      _messageController.clear();
                      _scrollToBottom();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
