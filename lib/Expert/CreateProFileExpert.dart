import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weather/Expert/ProfileController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class CreateProfilesPage extends StatefulWidget {
  const CreateProfilesPage({super.key});

  @override
  State<CreateProfilesPage> createState() => _CreateProfilesPageState();
}

class _CreateProfilesPageState extends State<CreateProfilesPage> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController(); // Kinh nghiệm
  final TextEditingController _supportGroupController = TextEditingController(); // Nhóm cây hỗ trợ
  XFile? _profilePic;
  String? userProfilePicture;
  String? userFullName;

  final _formKey = GlobalKey<FormState>();
  final ProfilesController _profilesController = Get.put(ProfilesController());
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _profilePic = image;
    });
  }

  Future<void> _loadUserInfo() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String? userEmail = currentUser.email;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .get();

      if (userDoc.exists) {
        String? fullName = userDoc['fullName'];
        String? profilePicture = userDoc['profilePicture'];

        setState(() {
          userFullName = fullName ?? 'User';
          userProfilePicture = profilePicture ?? 'https://www.w3schools.com/w3images/avatar2.png';  // Ảnh mặc định
        });
      } else {
        print('Không tìm ra thông tin người dùng');
      }
    }
  }


  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _profilesController.saveOrUpdateProfile(
          _fullnameController.text.trim(),
          _bioController.text.trim(),
          _degreeController.text.trim(),
          _experienceController.text.trim(),
          _supportGroupController.text.trim(),
          _profilePic,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu thành công!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu thông tin: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo thông tin chuyên gia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight, // Align the button to the bottom-right
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40.0,
                        backgroundImage: _profilePic != null
                            ? FileImage(File(_profilePic!.path))  // If the user picked an image
                            : (userProfilePicture != null
                            ? NetworkImage(userProfilePicture!) as ImageProvider  // Use stored profile picture if available
                            : const NetworkImage('https://www.w3schools.com/w3images/avatar2.png')),  // Default image if null
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    Positioned(
                      top: 45, // Place the button at the bottom
                      left: 45,  // Place the button to the right
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 25), // Icon to select the image
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _fullnameController,
                decoration: const InputDecoration(labelText: 'Họ và Tên'),
                initialValue: userFullName,  // Gán giá trị fullname từ Firestore
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nhập họ và tên';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Tiểu Sử'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nhập tiểu sử';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _degreeController,
                decoration: const InputDecoration(labelText: 'Học Vị'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nhập học vị';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(labelText: 'Số Năm Làm Việc'), // Trường Kinh nghiệm
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nhập số năm kinh nghiệm';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _supportGroupController,
                decoration: const InputDecoration(labelText: 'Nhóm cây hổ trợ'), // Trường Nhóm cây hỗ trợ
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nhập nhóm cây hổ trợ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.purple[500], // Background color of the button
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Make text bold
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
