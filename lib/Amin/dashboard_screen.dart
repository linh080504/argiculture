import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chào mừng đến với MobiAgri!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('Dưới đây là thông tin tổng quan về ứng dụng:', style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          _buildStatsCard(),
          SizedBox(height: 16),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thống kê nhanh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Số người dùng: 120', style: TextStyle(fontSize: 16)),
                    Text('Số thuốc: 50', style: TextStyle(fontSize: 16)),
                    Text('Số cây trồng: 30', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Icon(Icons.insert_chart, size: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hoạt động gần đây', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ListTile(
              title: Text('Người dùng mới: Nguyễn Văn A'),
              subtitle: Text('Đăng ký vào lúc 10:30 AM'),
            ),
            ListTile(
              title: Text('Cập nhật thuốc: Paracetamol'),
              subtitle: Text('Cập nhật vào lúc 11:00 AM'),
            ),
            ListTile(
              title: Text('Thêm cây trồng: Lúa'),
              subtitle: Text('Thêm vào lúc 11:15 AM'),
            ),
          ],
        ),
      ),
    );
  }
}
