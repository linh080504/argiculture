import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:weather/UI/ComunityPage/PostController.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostCreate extends StatefulWidget {
  const PostCreate({super.key});

  @override
  State<PostCreate> createState() => _PostCreateState();
}

class _PostCreateState extends State<PostCreate> {
  final TextEditingController _titleController = TextEditingController();
  final postController = Get.find<PostController>();
  XFile? _imageFile;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fullname = prefs.getString('fullname');
    print('fullname: $fullname');
    setState(() {
      userName = fullname ?? 'Người dùng';
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _imageFile = pickedImage;
      }
    });
  }

  Future<void> addPost() async {
    if (_titleController.text.isNotEmpty) {
      postController.title.value = _titleController.text;
      await postController.addPost(userName!);
      Navigator.pop(context);
    } else if (_titleController.text.isEmpty) {
      Get.snackbar(
        "Add title first",
        "Please enter a title for the post",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        icon: Icon(Icons.warning_amber_rounded),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleField = TextField(
      controller: _titleController,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        hintText: 'Enter a title',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _titleController.clear();
                ;
              },
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () {
                pickImage;
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
        title: const Text('Create new post'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            titleField,
            const SizedBox(height: 20),
            _imageFile != null
                ? Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  )
                : Container(),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  postController.title.value = _titleController.text;
                  await postController
                      .addPost(userName!);
                  Navigator.pop(context);
                  _titleController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Please enter a title for the post",
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
              child: Text(
                "Post",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.blue,
              ),
            )
          ],
        ),
      ),
    );
  }
}
