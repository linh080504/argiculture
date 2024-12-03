import 'package:flutter/material.dart';
import 'package:weather/Expert/ProfileController.dart';
import 'package:get/get.dart'; // Import lớp ExpertData

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: expertData.profilePictureUrl.isNotEmpty
                          ? NetworkImage(expertData.profilePictureUrl)
                          : AssetImage('assets/images/placeholder.png'),  // Add a placeholder image
                      child: expertData.profilePictureUrl.isEmpty
                          ? const Icon(Icons.person, size: 30, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      expertData.degree,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                    subtitle: Text(
                      expertData.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.blue[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.wechat_outlined, color: Colors.indigoAccent),
                          label: Text('Tư vấn', style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigoAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            side: BorderSide(color: Colors.indigoAccent),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add_call, color: Colors.white),
                          label: Text('Liên hệ', style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[500],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            side: BorderSide(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kinh nghiệm: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  expertData.experience.isEmpty
                      ? 'Chưa có thông tin'
                      : expertData.experience,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Nhóm hỗ trợ: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  expertData.supportGroup.isEmpty
                      ? 'Chưa có thông tin'
                      : expertData.supportGroup,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Thành tích: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  expertData.bio.isEmpty ? 'Chưa có thông tin' : expertData.bio,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),

            // Danh sách các chuyên gia khác theo dạng ngang (horizontal scroll)
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
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: otherExperts.length,
                itemBuilder: (context, index) {
                  final expert = otherExperts[index];
                  return Container(
                    width: 400,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowInformationPage(expertData: expert),
                                ),
                              );
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: expert.profilePictureUrl.isNotEmpty
                                    ? NetworkImage(expert.profilePictureUrl)
                                    : AssetImage('assets/images/placeholder.png'), // Placeholder image
                                child: expert.profilePictureUrl.isEmpty
                                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                                    : null,
                              ),
                              title: Text(
                                expert.degree,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                ),
                              ),
                              subtitle: Text(
                                expert.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.blue[100],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.wechat_outlined, color: Colors.indigoAccent),
                                  label: Text('Tư vấn', style: TextStyle(fontSize: 14)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.indigoAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    side: BorderSide(color: Colors.indigoAccent),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.add_call, color: Colors.white),
                                  label: Text('Liên hệ', style: TextStyle(fontSize: 14)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[500],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    side: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
}
