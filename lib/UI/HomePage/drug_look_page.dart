import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';
<<<<<<< HEAD
import 'package:weather/UI/HomePage/build_allowed_drug_content.dart'; // Nhập khẩu file mới
=======
>>>>>>> d58dd9af06300eef7fc4b1075ef30612109c5ddf

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
<<<<<<< HEAD
          buildAllowedDrugContent(), // Gọi hàm đã chuyển
=======
          _buildAllowedDrugContent(),
>>>>>>> d58dd9af06300eef7fc4b1075ef30612109c5ddf
          // Nội dung cho tab "Thuốc cấm sử dụng"
          _buildBannedDrugContent(),
        ],
      ),
    );
  }

<<<<<<< HEAD
  // Hàm này giữ nguyên
=======
  Widget _buildAllowedDrugContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container hiển thị phần nội dung thuốc
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // ListView cuộn ngang hiển thị danh sách thuốc
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildDrugItem("assets/drug_a.png", "Thuốc A"),
                        _buildDrugItem("assets/drug_b.png", "Thuốc B"),
                        _buildDrugItem("assets/drug_c.png", "Thuốc C"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Card lớn chứa ô tìm kiếm và 2 Card con
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Ô tìm kiếm
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Tìm kiếm',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Dòng chứa 2 Card con
                          Row(
                            children: [
                              // Cột 1: Card icon và cây trồng
                              Expanded(
                                child: Card(
                                  elevation: 4,
                                  color: Colors.green.withOpacity(0.4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.eco, size: 40, color: Colors.green),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Cây trồng',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Cột 2: Card icon và dịch hại
                              Expanded(
                                child: Card(
                                  elevation: 4,
                                  color: Colors.blueAccent.withOpacity(0.4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.bug_report, size: 40, color: Colors.blue),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Dịch hại',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Số lượng hiện có
                  const Text(
                    'Số lượng hiện có (1765)',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10), // Khoảng cách trước dòng mới

                  // Dòng chứa thông tin thuốc
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Căn giữa
                    children: [
                      // Card 1 chứa thông tin thuốc
                      Expanded(
                        child: _buildInfoCard(
                          imagePath: "assets/thuoctrusau.jpg",
                          drugName: "Thuốc CARBO MAX",
                          registrationUnit: "Tên đơn vị đăng ký thuốc: ",
                          companyName: "Công ty TNHH Dược phẩm Nam Việt",
                          drugType: "Thuốc trừ sâu",
                        ),
                      ),
                      const SizedBox(width: 16), // Khoảng cách giữa 2 card

                      // Card 2 chứa thông tin thuốc
                      Expanded(
                        child: _buildInfoCard(
                          imagePath: "assets/thuocdietco.jpg",
                          drugName: "Thuốc Topical",
                          registrationUnit: "Tên đơn vị đăng ký thuốc: ",
                          companyName: "Công ty Cổ phần bảo vệ thực vật 1 Trung Ương",
                          drugType: "Thuốc diệt cỏ",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Hàm xây dựng card thông tin thuốc
  Widget _buildInfoCard({
    required String imagePath,
    required String drugName,
    required String registrationUnit,
    required String companyName,
    required String drugType,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn chỉnh các phần tử bên trong card
          children: [
            // Ảnh thuốc
            Image.asset(
              imagePath,
              height: 110, // Chiều cao của ảnh
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),

            // Tên thuốc
            Text(
              drugName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // Căn giữa tên thuốc
            ),
            const SizedBox(height: 4),

            // Đơn vị đăng ký
            Text(
              registrationUnit,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center, // Căn giữa đơn vị đăng ký
            ),
            const SizedBox(height: 4),

            // Tên công ty
            Text(
              companyName,
              style: const TextStyle(fontSize: 14, color: Colors.green),
              textAlign: TextAlign.center, // Căn giữa tên công ty
            ),
            const SizedBox(height: 10),

            // Tên loại thuốc
            Text(
              drugType,
              style: const TextStyle(fontSize: 14, color: Colors.blue),
              textAlign: TextAlign.center, // Căn giữa tên loại thuốc
            ),
          ],
        ),
      ),
    );
  }


// Hàm xây dựng item của thuốc bao gồm hình tròn và tên thuốc
  Widget _buildDrugItem(String imagePath, String drugName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40, // Kích thước của hình tròn
            backgroundImage: AssetImage(imagePath), // Ảnh của thuốc
          ),
          const SizedBox(height: 8),
          Text(
            drugName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }




>>>>>>> d58dd9af06300eef7fc4b1075ef30612109c5ddf
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
