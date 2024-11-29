import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/UI/login.dart';
import 'package:weather/UI/CommunityPage.dart';
import 'package:weather/Components/color.dart';
import 'package:weather/Expert/Chat_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather/Expert/CreateProFileExpert.dart';
import 'package:weather/Expert/ProfileController.dart';

class ExpertHome extends StatefulWidget {
  const ExpertHome({super.key});

  @override
  _ExpertHomeState createState() => _ExpertHomeState();
}

class _ExpertHomeState extends State<ExpertHome> {
  String? userName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  String? userProfilePicture;
  File? _avatarImage;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _widgetOptions = [
    ChatScreen(),
    CommunityPage(),
  ];

  bool shouldShowAppBar(int index) {
    return index == 0;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  void initState() {
    super.initState();
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
        String? fullname = userDoc['fullname'];
        setState(() {
          userName = fullname ?? 'Người dùng';
        });
      } else {
        print('User document not found');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: shouldShowAppBar(_selectedIndex)
          ? AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.menu_sharp, color: Colors.white, size: 30),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 30),
            Text(
              'Chat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 28,
              ),
            ),
            SizedBox(width: 100),
          ],
        ),
        centerTitle: true,
      )
          : null,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28.0,
                        backgroundImage: _avatarImage != null
                            ? FileImage(_avatarImage!)
                            : userProfilePicture != null
                            ? NetworkImage(userProfilePicture!)
                        as ImageProvider
                            : NetworkImage(
                            'https://www.w3schools.com/w3images/avatar2.png'),
                      ),
                      Positioned(
                        top: 30,
                        left: 30,
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final pickedImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
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
                  SizedBox(width: 16.0),
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
            ListTile(
              leading: Icon(Icons.app_registration, color: Colors.black),
              title: Text(
                'Create Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateProfilesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.outlet_sharp, color: Colors.black),
              title: Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Cộng đồng',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

