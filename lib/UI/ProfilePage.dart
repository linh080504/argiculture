import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/Components/color.dart';
import 'package:weather/UI/forgot_password.dart';
import 'package:weather/UI/login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userEmail;
  String? userName;
  String? userProfilePicture;
  String? userBio;
  File? _avatarImage;

  late final FirebaseAuth _auth;
  User? user;
  TextEditingController _bioController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _loadUserName();
  }

  void _loadUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userEmail = currentUser.email ?? '';

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .get();

      if (userDoc.exists) {
        String? fullName = userDoc['fullName'];
        String? profilePicture = userDoc['profilePicture'];

        setState(() {
          userName = fullName ?? 'Người dùng';
          userProfilePicture = profilePicture ?? '';
        });
      } else {
        print('User document not found');
      }
    }
  }


  void _updateUserBio(String newBio) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // Cập nhật tiểu sử của người dùng trên Firestore
        await FirebaseFirestore.instance.collection('users').doc(currentUser.email).update({
          'TieuSu': newBio,
        });

        setState(() {
          userBio = newBio;  // Cập nhật lại tiểu sử trong UI
        });
      } catch (error) {
        print('Error updating user bio: $error');
      }
    }
  }

  void _updateDisplayName(String newName) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.updateProfile(displayName: newName);

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(user.email).update({
          'fullName': newName,
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullName', newName);

        setState(() {
          userName = newName;
        });

      } catch (error) {
        print('Error updating user profile: $error');
      }
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _pickAvatarImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _avatarImage = File(pickedImage.path);
      });

      await _uploadAvatarImageToFirebase(pickedImage);
    }
  }

  Future<void> _uploadAvatarImageToFirebase(XFile image) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child('avatars/$fileName');
        UploadTask uploadTask = ref.putFile(File(image.path));

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(currentUser.email).update({
          'profilePicture': downloadUrl,
        });

        setState(() {
          userProfilePicture = downloadUrl;
        });
      }
    } catch (e) {
      print("Error uploading avatar image: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,  // Chọn màu sắc mới cho app bar
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28.0,
                  backgroundImage: userProfilePicture != null && userProfilePicture!.isNotEmpty
                      ? NetworkImage(userProfilePicture!)
                      : const NetworkImage('https://www.w3schools.com/w3images/avatar2.png'), // Ảnh mặc định nếu không có ảnh đại diện
                  backgroundColor: Colors.grey[200],
                ),
                Positioned(
                  top: 30,
                  left: 30,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: _pickAvatarImage,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.0),
            Text(
              '$userName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Màu chữ
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Tiểu sử
              TextField(
                controller: _bioController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Tiểu sử',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.edit_note),
                    onPressed: () {
                      String newBio = _bioController.text.trim();
                      if (newBio.isNotEmpty) {
                        _updateUserBio(newBio);  // Cập nhật tiểu sử mới
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Đổi tên
              ListTile(
                leading: Icon(Icons.account_circle_rounded, color: Colors.deepPurple),
                title: Text('Đổi tên', style: TextStyle(fontSize: 16, color: Colors.black)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      TextEditingController _nameController = TextEditingController(text: userName);
                      return AlertDialog(
                        title: Text('Nhập tên mới'),
                        content: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(hintText: 'Tên mới'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              if (_nameController.text.isNotEmpty) {
                                _updateDisplayName(_nameController.text);  // Cập nhật tên mới
                              }
                            },
                            child: Text('Xác nhận'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Hủy'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              // Đổi mật khẩu
              ListTile(
                leading: Icon(Icons.password, color: Colors.deepPurple),
                title: Text('Đổi mật khẩu', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPassword(),
                    ),
                  );
                },
              ),
              // Đăng xuất
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.deepPurple),
                title: Text('Đăng xuất', style: TextStyle(fontSize: 16)),
                onTap: _logout,
              ),
              // Xóa tài khoản
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Xóa tài khoản', style: TextStyle(fontSize: 16, color: Colors.red)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Xác nhận xóa tài khoản'),
                        content: Text('Bạn có chắc chắn muốn xóa tài khoản của mình không?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Xác nhận'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
