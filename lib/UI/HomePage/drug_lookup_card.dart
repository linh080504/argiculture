// drug_lookup_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'drug_look_page.dart'; // Đảm bảo bạn import trang DrugLookPage

class DrugLookupCard extends StatelessWidget {
  const DrugLookupCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Đảm bả o Card chiếm toàn bộ chiều rộng
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          // Gắn background cho Card
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_card.jpg'), // Thay bằng đường dẫn đến hình nền
              fit: BoxFit.cover, // Đảm bảo hình ảnh phủ đầy
            ),
            color: Colors.white, // Màu nền của Card
            borderRadius: BorderRadius.circular(10), // Cạnh bo tròn
          ),
          padding: const EdgeInsets.all(16.0),
          width: double.infinity, // Chiều rộng của Card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dòng chứa "Tra cứu thuốc" và "Tra cứu ngay"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn đều 2 bên
                children: [
                  const Text(
                    "Tra cứu thuốc",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DrugLookPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Tra cứu ngay",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hai mục thuốc
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn đều 2 bên
                children: [
                  // Card 1: Thuốc BVTV được phép lưu hành
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DrugLookPage(),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: const Column(
                            children: [
                              // Dòng 1: Icon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.pills, size: 50, color: Colors.blue),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Dòng 2: Tiêu đề
                              const Text(
                                "Thuốc BVTV được phép lưu hành",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Khoảng cách giữa 2 cột
                  // Card 2: Thuốc BVTV cấm lưu hành
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DrugLookPage(),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: const Column(
                            children: [
                              // Dòng 1: Icon
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.pills, size: 50, color: Colors.red),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Dòng 2: Tiêu đề
                              const Text(
                                "Thuốc BVTV cấm lưu hành",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
    );
  }
}
