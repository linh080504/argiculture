import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather/Components/color.dart';
import 'package:weather/UI/home.dart';
import 'package:weather/Expert/ProfileCard.dart';
import 'package:weather/Expert/ProfileController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertPage extends StatelessWidget {
  final profileController = Get.put(ProfilesController());

  ExpertPage({Key? key}) : super(key: key) {
    profileController.fetchExpertProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Màu nền trắng
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50), // Màu xanh lá cây tươi sáng
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          },
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Chuyên Gia Nông Nghiệp',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        centerTitle: true, // Tiêu đề nằm chính giữa
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (profileController.expertList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4CAF50)), // Màu xanh lá cho vòng xoay
                  SizedBox(height: 20),
                  Text(
                    'Đang tải hồ sơ...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: profileController.expertList.length,
              itemBuilder: (context, index) {
                final expert = profileController.expertList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ProfileCard(expertData: expert),
                );
              },
            );
          }
        }),
      ),
    );
  }
}
