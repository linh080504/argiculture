import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/UI/ComunityPage/PostController.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather/UI/ComunityPage/PostCard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weather/UI/ComunityPage/CommentCard.dart';

class CommentList extends StatefulWidget {
  final String postId;

  const CommentList({super.key, required this.postId});

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final TextEditingController _titlecmtController = TextEditingController();
  final commentController = Get.find<PostController>();
  String? userName;
  String? postUser;
  String? postTitle;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchPostDetails();
    commentController.fetchComments(widget.postId);
  }

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImageFile != null) {
        _imageFile = pickedImageFile;
      }
    });
  }

  Future<void> _fetchPostDetails() async {
    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (postSnapshot.exists) {
        setState(() {
          postTitle = postSnapshot['title'];
          postUser = postSnapshot['user'];
        });
      }
    } catch (e) {
      print("Error fetching post details: $e");
    }
  }

  void _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fullname = prefs.getString('fullname');
    setState(() {
      userName = fullname ?? 'Người dùng';
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentInputField = TextField(
      controller: _titlecmtController,
      decoration: InputDecoration(
        fillColor: Colors.grey.shade100,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: 'Nhập bình luận...',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _titlecmtController.clear();
              },
            ),
            IconButton(
              icon: Icon(Icons.add_a_photo, color: Colors.blue),
              onPressed: pickImage,
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.green),
              onPressed: () async {
                final commentText = _titlecmtController.text.trim();
                if (commentText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập bình luận.')),
                  );
                  return;
                }

                try {
                  await commentController.addComment(
                      widget.postId, commentText, _imageFile);
                  _titlecmtController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm bình luận thành công!')),
                  );
                  commentController.fetchComments(widget.postId);
                } catch (e, stackTrace) {
                  print('Error adding comment: $e');
                  print(stackTrace);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Lỗi khi thêm bình luận: $e",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },

            ),
          ],
        ),
      ),
      style: TextStyle(color: Colors.black87, fontSize: 16),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Bài viết của ${postUser ?? "Không rõ"}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: postTitle != null
          ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PostCard(
                post: Post(
                  id: widget.postId,
                  user: postUser ?? 'Không rõ',
                  title: postTitle!,
                  images: [],
                  comments: [],
                  timestamp: DateTime.now(),
                ),
              ),
            ),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Bình luận:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Obx(() {
              if (commentController.comments.isEmpty) {
                return Center(child: Text('Chưa có bình luận.'));
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: commentController.comments.length,
                  itemBuilder: (context, index) {
                    final comment = commentController.comments[index];
                    return CommentCard(comment: comment);
                  },
                );
              }
            }),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: commentInputField,
            ),
          ],
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
