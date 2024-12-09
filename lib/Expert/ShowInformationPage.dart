import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather/Expert/ProfileController.dart'; // Import lớp ExpertData

class ShowInformationPage extends StatelessWidget {
  final ExpertData expertData;

  const ShowInformationPage({
    Key? key,
    required this.expertData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfilesController controller = Get.find();
    List<ExpertData> otherExperts = controller.expertList
        .where((expert) => expert.id != expertData.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Information Section
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: expertData.profilePictureUrl.isNotEmpty
                          ? NetworkImage(expertData.profilePictureUrl)
                          : AssetImage('assets/images/placeholder.png'),
                      child: expertData.profilePictureUrl.isEmpty
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expertData.fullName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          expertData.degree,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Expertise Details
            _buildInfoSection('Kinh nghiệm:', expertData.experience),
            _buildInfoSection('Nhóm hỗ trợ:', expertData.supportGroup),
            _buildInfoSection('Thành tích:', expertData.bio),

            // Other Experts Section
            SizedBox(height: 16),
            Text(
              'Các chuyên gia khác:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: otherExperts.length,
                itemBuilder: (context, index) {
                  final expert = otherExperts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowInformationPage(expertData: expert),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container( // Đặt Container bên trong Card để kiểm soát chiều rộng
                        width: 150, // Tăng chiều rộng của phần tử
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: expert.profilePictureUrl.isNotEmpty
                                  ? NetworkImage(expert.profilePictureUrl)
                                  : AssetImage('assets/images/placeholder.png'),
                              child: expert.profilePictureUrl.isEmpty
                                  ? const Icon(Icons.person, size: 35, color: Colors.white)
                                  : null,
                            ),
                            SizedBox(height: 8),
                            Text(
                              expert.fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              expert.degree,
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.call, color: Colors.white),
                              label: Text('Liên hệ', style: TextStyle(fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            content.isEmpty ? 'Chưa có thông tin' : content,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
