import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String fullName;
  final String bio;
  final String degree;
  final String profilePictureUrl;

  const ProfileCard({
    Key? key,
    required this.fullName,
    required this.bio,
    required this.degree,
    required this.profilePictureUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 5, // Thêm độ nổi để tạo cảm giác mượt mà hơn
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Làm tròn góc của card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần hiển thị ảnh đại diện và thông tin cơ bản
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: profilePictureUrl.isNotEmpty
                  ? NetworkImage(profilePictureUrl)
                  : null,
              child: profilePictureUrl.isEmpty
                  ? const Icon(Icons.person,
                      size: 30,
                      color: Colors.white) // Biểu tượng người nếu không có ảnh
                  : null,
            ),
            title: Text(
              fullName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                bio,
                style: TextStyle(
                  color: Colors.grey[700], // Màu chữ phụ
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Phần hiển thị học vị
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '$degree',
              style: const TextStyle(
                color: Colors.black54, // Màu chữ nhẹ hơn
                fontSize: 14,
                fontStyle: FontStyle.italic, // Thêm kiểu chữ nghiêng cho học vị
              ),
            ),
          ),

          // Đoạn chia cách (divider) giữa các thông tin
          Divider(
            color: Colors.grey[300],
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          Container(
            color: Colors.blue[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.wechat_outlined, color: Colors.indigoAccent),
                  label: Text(
                    'Tư vấn',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                    side: BorderSide(color: Colors.indigoAccent),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add_call, color: Colors.white),
                  label: Text(
                    'Liên hệ',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                    side: BorderSide(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
