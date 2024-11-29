import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/UI/forgot_password.dart';
import 'package:weather/UI/login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userEmail;
  String? userName;
  String? userProfilePicture;
  File? _avatarImage;

  late final FirebaseAuth _auth;
  User? user;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _loadUserName();
  }

  // Hàm để tải dữ liệu người dùng từ Firebase Authentication và Firestore
  void _loadUserName() async {
    // Lấy user hiện tại từ Firebase Authentication
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userEmail = currentUser.email ?? '';

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Tên collection của bạn
          .doc(userEmail) // Sử dụng email làm documentId
          .get();

      if (userDoc.exists) {
        String? fullname = userDoc['fullname']; // Lấy fullname từ Firestore
        print('fullname: $fullname');
        setState(() {
          userName = fullname ?? 'Người dùng'; // Nếu không có fullname, hiển thị "Người dùng"
        });
      } else {
        print('User document not found');
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

  // Hàm cập nhật tên người dùng trong Firestore và Firebase
  void _updateDisplayName(String newName) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Cập nhật tên người dùng trong Firebase Authentication
        await user.updateProfile(displayName: newName);

        // Cập nhật tên người dùng trong Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(user.email).update({
          'fullName': newName,
        });

        // Lưu thông tin vào SharedPreferences nếu cần
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullname', newName);

        setState(() {
          userName = newName;
        });

      } catch (error) {
        print('Error updating user profile: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28.0,
                    backgroundImage: _avatarImage != null
                        ? FileImage(_avatarImage!)
                        : userProfilePicture != null
                        ? NetworkImage(userProfilePicture!) as ImageProvider
                        : NetworkImage('https://www.w3schools.com/w3images/avatar2.png'),
                  ),
                  Positioned(
                    top: 30,
                    left: 30,
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedImage != null) {
                          setState(() {
                            _avatarImage = File(pickedImage.path);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.0), // Add spacing between avatar and text
              Text(
                '$userName',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.mode_edit_outlined),
                    hintText: 'Tiểu sử',
                  ),
                  onChanged: (value) {},
                ),
                ListTile(
                  leading: Icon(Icons.account_circle_rounded),
                  title: Text('Đổi tên'),
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
                                  _updateDisplayName(_nameController.text); // Update the Firebase displayName
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
                ListTile(
                  leading: Icon(Icons.password),
                  title: Text('Đổi mật khẩu'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPassword(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.outlet_sharp),
                  title: Text('Đăng xuất'),
                  onTap: () {
                    _logout();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Xóa tài khoản'),
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
        )
    );
  }
}

