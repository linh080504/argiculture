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
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchPostDetails();
    commentController.fetchComments(widget.postId);
    setState(() {});
  }

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImageFile != null) {
        _imageFile = pickedImageFile;
        print(_imageFile!.path);
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
    print('fullname: $fullname');
    setState(() {
      userName = fullname ?? 'Người dùng';
    });
  }

  @override
  Widget build(BuildContext context) {
    final titcmtleField = TextField(
      controller: _titlecmtController,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        hintText: 'Enter a title',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _titlecmtController.clear();
                ;
              },
            ),
            SizedBox(width: 2),
            IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () {
                pickImage;
              },
            ),
            SizedBox(width: 2),
            IconButton(
              icon: Icon(Icons.arrow_circle_right_outlined),
              onPressed: () async {
                final commentText = _titlecmtController.text.trim();
                if (commentText.isEmpty) {
                  // Handle empty comment case
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a comment.')),
                  );
                  return;
                }
                try {
                  await commentController.addComment(
                      widget.postId, userName!, commentText);
                  _titlecmtController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Comment added successfully!')),
                  );
                  commentController.fetchComments(widget.postId);
                } catch (e) {
                  print('Error adding comment: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Lỗi vui lòng comment lại",
                              style: TextStyle(
                                  color: Colors.white),
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
      style: TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Post is by ${postUser ?? "Unknown"}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: postTitle != null
          ? SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(
                    post: Post(
                      id: widget.postId,
                      user: postUser ?? 'Unknown',
                      title: postTitle!,
                      images: [],
                      comments: [],
                      timestamp: DateTime.now(),
                    ),
                  ),
                  const Divider(thickness: 1),
                  Container(
                  padding: const EdgeInsets.all(10),
                    child: Text(
                      'Danh sách bình luận',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: commentController.comments.length,
                    itemBuilder: (context, index) {
                      final comment = commentController.comments[index];
                      return CommentCard(comment: comment);
                    },
                  ),
                  titcmtleField,
                ],
              ),
            )
          : Container(),
    );
  }
}
