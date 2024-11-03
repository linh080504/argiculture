import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';
import 'package:weather/UI/HomePage/build_allowed_drug_content.dart'; // Nhập khẩu file mới

class DrugLookPage extends StatefulWidget {
  const DrugLookPage({super.key});

  @override
  State<DrugLookPage> createState() => _DrugLookPageState();
}

class _DrugLookPageState extends State<DrugLookPage> {
  bool _isAllowedDrugExpanded = false; // Biến theo dõi trạng thái mở rộng của thuốc được phép
  bool _isBannedDrugExpanded = false; // Biến theo dõi trạng thái mở rộng của thuốc cấm
  int _bottomNavIndex = 0; // Chỉ số tab hiện tại (0 cho thuốc được sử dụng)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra cứu thuốc'),
        backgroundColor: Colors.white70, // Màu nền của AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // Chiều cao của thanh điều hướng
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: 'Thuốc được sử dụng',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: 'Thuốc cấm sử dụng',
              ),
            ],
            currentIndex: _bottomNavIndex,
            selectedItemColor: Colors.green,
            backgroundColor: Colors.white70, // Màu nền của BottomNavigationBar
            onTap: (index) {
              setState(() {
                _bottomNavIndex = index; // Cập nhật chỉ số tab hiện tại
              });
            },
          ),
        ),
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          // Nội dung cho tab "Thuốc được sử dụng"
          buildAllowedDrugContent(), // Gọi hàm đã chuyển
          // Nội dung cho tab "Thuốc cấm sử dụng"
          _buildBannedDrugContent(),
        ],
      ),
    );
  }

  // Hàm này giữ nguyên
  Widget _buildBannedDrugContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Đệm cho toàn bộ nội dung
      child: Column(
        children: [
          // Mục Thuốc cấm sử dụng
          GestureDetector(
            onTap: () {
              setState(() {
                _isBannedDrugExpanded = !_isBannedDrugExpanded; // Chuyển đổi trạng thái mở rộng
                if (_isAllowedDrugExpanded) {
                  _isAllowedDrugExpanded = false; // Đóng phần thuốc được phép nếu nó đang mở
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16.0), // Đệm cho container
              color: Colors.red[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Thuốc cấm sử dụng",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Icon(_isBannedDrugExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          if (_isBannedDrugExpanded) ...[
            const SizedBox(height: 10),
            const Text(
              "Danh sách các thuốc cấm sử dụng: \n- Thuốc D \n- Thuốc E \n- Thuốc F",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
