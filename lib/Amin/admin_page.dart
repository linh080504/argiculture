import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/Amin/dashboard_screen.dart';
import 'package:weather/Amin/disease_predicttion_page.dart';
import 'package:weather/Amin/plants/crop_controller.dart';
import 'package:weather/Components/color.dart';

// Import các trang quản lý
import 'drugs/drugs_management_page.dart';
import 'users_management_page.dart';
import 'plants/crops_management_page.dart';
import 'statistics_page.dart';
import 'settings_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Widget _currentBody;
  late CropController cropController; // Khai báo controller
  String _selectedRoute = '/dashboard';

  @override
  void initState() {
    super.initState();
    _currentBody = DashboardScreen();
    cropController = CropController(); // Khởi tạo CropController
  }

  void _onMenuItemSelected(AdminMenuItem item) {
    setState(() {
      _selectedRoute = item.route!;
      if (item.route == '/logout') {
        _logout(context);
      } else if (item.route == '/drugs') {
        _currentBody = DrugsManagementPage();
      } else if (item.route == '/dashboard') {
        _currentBody = DashboardScreen();
      } else if (item.route == '/users') {
        _currentBody = UsersManagementPage();
      } else if (item.route == '/crops') {
        _currentBody = CropsManagementPage(cropController: cropController);
      } else if (item.route == '/disease-prediction') {
        _currentBody = DiseasePredictionPage();
      } else if (item.route == '/statistics') {
        _currentBody = StatisticsPage();
      } else if (item.route == '/settings') {
        _currentBody = SettingsPage();
      }
    });
  }

  Widget _buildMenuItem(String title, String route, IconData icon) {
    bool isSelected = _selectedRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blueAccent : Colors.grey[700],
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        leading: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey[700], size: 26),
        tileColor: isSelected ? Colors.blue[50] : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        onTap: () {
          _onMenuItemSelected(AdminMenuItem(title: title, route: route, icon: icon));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        title: Text(
          'MobiAgri - Dashboard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 4.0, // Hiệu ứng bóng mờ nhẹ
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
        backgroundColor: primaryColor.withOpacity(0.2),
        selectedRoute: _selectedRoute,
        onSelected: _onMenuItemSelected,
        header: Container(
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primaryColor,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Text(
            'Admin Menu',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: _currentBody,
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }
}
