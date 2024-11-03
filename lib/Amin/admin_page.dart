import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/Amin/dashboard_screen.dart';
import 'package:weather/Amin/disease_predicttion_page.dart';
import 'package:weather/Components/color.dart';

// Import các trang quản lý
import 'drugs/drugs_management_page.dart'; // Đảm bảo import đúng đường dẫn
import 'users_management_page.dart';  // Giả sử có trang quản lý người dùng
import 'crops_management_page.dart';  // Giả sử có trang quản lý cây trồng
import 'statistics_page.dart';         // Giả sử có trang thống kê
import 'settings_page.dart';           // Giả sử có trang cài đặt

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Widget _currentBody;
  String _selectedRoute = '/dashboard'; // Mục đang được chọn

  @override
  void initState() {
    super.initState();
    _currentBody = DashboardScreen(); // Khởi tạo body với Dashboard
  }

  void _onMenuItemSelected(AdminMenuItem item) {
    setState(() {
      _selectedRoute = item.route!; // Cập nhật route được chọn
      if (item.route == '/logout') {
        _logout(context);
      } else if (item.route == '/drugs') {
        // Điều hướng đến DrugsManagementPage
        _currentBody = DrugsManagementPage(); // Cập nhật body với trang quản lý thuốc
      } else if (item.route == '/dashboard') {
        // Điều hướng về Dashboard
        _currentBody = DashboardScreen(); // Khôi phục lại Dashboard
      } else if (item.route == '/users') {
        _currentBody = UsersManagementPage(); // Cập nhật body với trang quản lý người dùng
      } else if (item.route == '/crops') {
        _currentBody = CropsManagementPage(); // Cập nhật body với trang quản lý cây trồng
      } else if (item.route == '/disease-prediction') {
        _currentBody = DiseasePredictionPage(); // Cập nhật body với trang dự đoán bệnh
      } else if (item.route == '/statistics') {
        _currentBody = StatisticsPage(); // Cập nhật body với trang thống kê
      } else if (item.route == '/settings') {
        _currentBody = SettingsPage(); // Cập nhật body với trang cài đặt
      }
    });
  }

  Widget _buildMenuItem(String title, String route, IconData icon) {
    bool isSelected = _selectedRoute == route;
    return ListTile(
      title: Text(title, style: TextStyle(color: isSelected ? Colors.blue : Colors.grey)),
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      onTap: () {
        _onMenuItemSelected(AdminMenuItem(title: title, route: route, icon: icon));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        title: Text('MobiAgri - Dashboard'),
        backgroundColor: primaryColor,
      ),
      sideBar: SideBar(
        items: [
          AdminMenuItem(title: 'Dashboard', route: '/dashboard', icon: Icons.dashboard),
          AdminMenuItem(title: 'Quản lý người dùng', route: '/users', icon: Icons.people),
          AdminMenuItem(title: 'Quản lý thuốc', route: '/drugs', icon: Icons.medication),
          AdminMenuItem(title: 'Quản lý cây trồng', route: '/crops', icon: Icons.agriculture),
          AdminMenuItem(title: 'Dự đoán bệnh', route: '/disease-prediction', icon: Icons.analytics),
          AdminMenuItem(title: 'Thống kê', route: '/statistics', icon: Icons.show_chart),
          AdminMenuItem(title: 'Cài đặt', route: '/settings', icon: Icons.settings),
          AdminMenuItem(title: 'Logout', route: '/logout', icon: Icons.logout),
        ],
        backgroundColor: primaryColor.withOpacity(0.3),
        selectedRoute: _selectedRoute, // Màu sắc mục được chọn
        onSelected: _onMenuItemSelected,
      ),
      body: _currentBody, // Hiển thị body hiện tại
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Xóa thông tin đăng nhập
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa tất cả dữ liệu

    // Điều hướng về trang đăng nhập
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }
}
