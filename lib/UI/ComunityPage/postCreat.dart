import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:weather/UI/ComunityPage/PostController.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostCreate extends StatefulWidget {
  const PostCreate({super.key});

  @override
  State<PostCreate> createState() => _PostCreateState();
}

class _PostCreateState extends State<PostCreate> {
  final TextEditingController _titleController = TextEditingController();
  final postController = Get.find<PostController>(); // Create an instance of PostController
  List<XFile> _imageFiles = []; // Non-nullable list initialized

  // Pick images from gallery
  Future<void> pickImages() async {
    final imagePicker = ImagePicker();
    final pickedImages = await imagePicker.pickMultiImage();

    setState(() {
      if (pickedImages != null && pickedImages.isNotEmpty) {
        _imageFiles = pickedImages;
      } else {
        // Ensure _imageFiles remains an empty list if no images are picked
        _imageFiles.clear();
      }
    });
  }

  // Add post to Firestore
  Future<void> addPost() async {
    if (_titleController.text.isNotEmpty && _imageFiles.isNotEmpty) {
      List<XFile> selectedImages = _imageFiles; // Non-nullable list

      try {
        await postController.addPost(
          title: _titleController.text,
          images: selectedImages,
        );
        _titleController.clear();
        _imageFiles.clear(); // Clear images after posting

        print("Post created successfully!");
        Navigator.pop(context);
        postController.fetchPosts();
      } catch (e) {
        print("Error adding post: $e");
        Get.snackbar(
          "Error",
          "Có lỗi xảy ra khi đăng bài viết!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } else {
      // Ensure title and images are not empty before posting
      Get.snackbar(
        "Thông báo",
        "Vui lòng nhập tiêu đề và chọn hình ảnh.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleField = TextField(
      controller: _titleController,
      maxLines: 8,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        hintText: 'Nhập tiêu đề...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _titleController.clear();
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_a_photo, color: Colors.blue),
              onPressed: () {
                pickImages();
              },
            ),
          ],
        ),
      ),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        title: const Text(
          'Tạo bài viết mới',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleField,
            const SizedBox(height: 20),
            _imageFiles.isNotEmpty
                ? SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageFiles.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: FileImage(File(_imageFiles[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
                : Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  "Không có hình ảnh được chọn",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: addPost,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue,
                  elevation: 4,
                ),
                child: const Text(
                  "Đăng bài",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
