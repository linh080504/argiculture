import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          },
        ),
        title: Center(
          child: Text(
            'Chuyên Gia Nông Nghiệp       ',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (profileController.expertList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 10),
                  Text(
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
                return ProfileCard(expertData: expert);
              },
            );
          }
        }),
      ),
    );
  }
}
