import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather/UI/home.dart';
import 'package:weather/Expert/ProfileCard.dart';
import 'package:weather/Expert/ProfileController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertPage extends StatelessWidget {
  final profileController = Get.put(ProfilesController());

  ExpertPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 30),
            Text(
              'Chuyên gia nông nghiệp',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 21,
              ),
            ),
            SizedBox(width: 60),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Obx(() {
          // Kiểm tra nếu danh sách hồ sơ trống
          if (profileController.expertList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Đang tải hồ sơ...',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: profileController.expertList.length,
              itemBuilder: (context, index) {
                final expert = profileController.expertList[index];
                return ProfileCard(
                  fullName: expert.fullName,
                  bio: expert.bio,
                  degree: expert.degree,
                  profilePictureUrl: expert.profilePictureUrl,
                );
              },
            );
          }
        }),
      ),
    );
  }
}
