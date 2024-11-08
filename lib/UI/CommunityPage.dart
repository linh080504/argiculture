import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/UI/ComunityPage/postCreat.dart';
import 'package:get/get.dart';
import 'package:weather/UI/ComunityPage/postCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather/UI/ComunityPage/PostController.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String? userName;

  final PostController _postController = Get.put(PostController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _postController.fetchPosts();
  }

  // Hàm lấy tên tài khoản từ SharedPreferences
  void _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Người dùng'; // Nếu không có tên tài khoản, hiển thị "Người dùng"
    });
  }
  void handlePostAdded(Post newPost) {
    _postController.posts.insert(0, newPost);
  }


  @override
  Widget build(BuildContext context) {

    final newPostButton = Padding(
      padding: const EdgeInsets.all(10),
      child: FilledButton(
        style: FilledButton.styleFrom(
          elevation: 4,
          side: BorderSide(
              color: Colors.black, // Màu viền
              width: 1),
          backgroundColor: Colors.white,
        ),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostCreate(),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.edit,
              color: Colors.black,
            ),
            SizedBox(width: 8),
            Text(
              'Tạo bài viết mới',
              style: TextStyle(color: Colors.black),
            ),
            Spacer(),
            Icon(
              Icons.add_a_photo_outlined,
              color : Colors.black,
            ),
            SizedBox(width: 2),
          ],
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Cộng đồng mobiAgri',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 28,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            newPostButton,
            SizedBox(height: 7),
            Expanded(
              child: Obx(() {
                if (_postController.posts.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return ListView.builder(
                    itemCount: _postController.posts.length,
                    itemBuilder: (context, index) {
                      final post = _postController.posts[index];
                      return PostCard(post: post);
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

