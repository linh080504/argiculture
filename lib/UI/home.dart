import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/Components/color.dart';
import 'package:weather/UI/HomePage/home_page.dart';
import 'package:weather/UI/login.dart';
import 'package:weather/UI/menu_home/faq.dart';
import 'package:weather/UI/menu_home/introduce_app.dart';
import 'package:weather/UI/menu_home/partners.dart';
import 'package:weather/UI/menu_home/privacy_policy.dart';
import 'package:weather/UI/menu_home/term_of_use.dart';
import 'package:weather/UI/scan_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weather/UI/CommunityPage.dart';
import 'package:weather/UI/ExpertPage.dart';
import 'package:weather/UI/ProfilePage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _bottomNavIndex = 0; // Chỉ số của tab hiện tại
  String? userName;
  List<IconData> iconList = [
    Icons.home,
    Icons.favorite,
    Icons.person,
    Icons.circle,
  ];

  // GlobalKey để truy cập ScaffoldState
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Danh sách widget cho từng tab
  List<Widget> _widgetOptions() {
    return [
      HomePage(), // Tab Home
      CommunityPage(),// Tab Favorite
      ExpertPage(), // Tab Cart
     ProfilePage(), // Tab Profile
    ];
  }
  @override
  void initState() {
    super.initState();
    _loadUserName(); // Tải tên tài khoản khi khởi tạo màn hình
  }


  // Hàm lấy tên tài khoản từ SharedPreferences
  void _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fullname = prefs.getString('fullname');
    print('fullname: $fullname');
    setState(() {
      userName = fullname ?? 'Người dùng';
    });
  }
  // Hàm xử lý đăng xuất
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName'); // Xóa tên người dùng
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()), // Chuyển đến trang đăng nhập
          (Route<dynamic> route) => false, // Loại bỏ tất cả các trang trước đó
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Gán GlobalKey cho Scaffold
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white70, size: 30), // Nút ba gạch
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Mở menu khi nhấn vào nút ba gạch
          },
        ),
        title: const Center(
          child: Text(
            'mobiAgri',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white70, size: 30), // Kính lúp
            onPressed: () {
              // Thêm chức năng tìm kiếm nếu cần
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white70, size: 30), // Biểu tượng thông báo
                onPressed: () {
                  // Thêm chức năng cho biểu tượng thông báo nếu cần
                },
              ),
              Positioned(
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2), // Đệm để làm nổi bật số lượng
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red, // Màu nền cho số lượng
                    borderRadius: BorderRadius.circular(10), // Đường viền tròn
                  ),
                  child: const Center(
                    child: Text(
                      '1', // Số lượng thông báo
                      style: TextStyle(
                        color: Colors.white, // Màu chữ
                        fontSize: 12, // Kích thước chữ
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        backgroundColor: primaryColor,
      ),
      drawer: Drawer( // Thêm Drawer (menu bên trái)
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor, // Màu nền của phần tiêu đề menu
              ),
              child: Text(
                'Xin chào, $userName',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Giới thiệu về mobiAgri'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IntroductionLetter()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Chính sách bảo mật'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicy()),
                );
                setState(() {
                  _bottomNavIndex = 1; // Điều hướng về trang chủ
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Điều khoản sử dụng'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermsOfUse()),
                );
                setState(() {
                  _bottomNavIndex = 2;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Câu hỏi thường gặp'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQ()),
                );
                setState(() {
                  _bottomNavIndex = 3;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Đối tác của chúng tôi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Partners()),
                );
                setState(() {
                  _bottomNavIndex = 4;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.book_online),
              title: Text('Hướng dẫn nhanh'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _bottomNavIndex = 5;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.note_rounded),
              title: Text('Đề xuất và góp ý'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _bottomNavIndex = 6;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Chia sẻ ứng dụng'),
              onTap: () async {
                // Hiển thị danh sách các ứng dụng có thể chia sẻ
                await Share.share('Bạn muốn chia sẻ ứng dụng nào?'
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.outlet_sharp),
              title: Text('Đăng xuất'),
              onTap: () {
                Navigator.pop(context); // Đóng menu
                _logout(); // Gọi hàm đăng xuất
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _widgetOptions(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, PageTransition(child: const ScanPage(), type: PageTransitionType.bottomToTop));
        },
        child: Image.asset('assets/code-scan-two.png', height: 30.0),
        backgroundColor: primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(iconList[0], size: 30,),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(right: 50), // Điều chỉnh khoảng cách sang trái
              child: Icon(iconList[1], size: 30), // Kích thước biểu tượng Favorite
            ),
            label: 'Cộng đồng',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(left: 8.0), // Điều chỉnh khoảng cách sang trái
              child: Icon(iconList[2], size: 30), // Kích thước biểu tượng Favorite
            ),
            label: 'Chuyên gia',
          ),
          BottomNavigationBarItem(
            icon: Icon(iconList[3], size: 30,),
            label: 'Tài Khoản',
          ),
        ],
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black.withOpacity(0.5),
      ),
    );
  }
}
