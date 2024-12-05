import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:weather/UI/DrugsPage/drug_detail_page.dart';

class AllowedDrugContent extends StatefulWidget {
  @override
  _AllowedDrugContentState createState() => _AllowedDrugContentState();
}

class _AllowedDrugContentState extends State<AllowedDrugContent> {
  String selectedType = 'Tất cả'; // Loại thuốc mặc định
  // Hàm chuẩn hóa chuỗi
  String normalize(String input) {
    return removeDiacritics(input.toLowerCase());
  }

  // Hàm để cập nhật loại thuốc được chọn
  void _updateSelectedType(String type) {
    setState(() {
      selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('drugs').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có dữ liệu.'));
          }

          final drugs = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          // Lọc danh sách thuốc dựa trên loại thuốc được chọn
          final filteredDrugs = selectedType == 'Tất cả'
              ? drugs
              : drugs.where((drug) => normalize(drug['type']) == normalize(selectedType)).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            _buildDrugItem("assets/khien.png", "Tất cả", Colors.purple.withOpacity(0.4), () => _updateSelectedType('Tất cả')),
                            _buildDrugItem("assets/sau.png", "Thuốc trừ sâu", Colors.amber.withOpacity(0.4), () => _updateSelectedType('Thuốc trừ sâu')),
                            _buildDrugItem("assets/co.png", "Thuốc trừ cỏ", Colors.blueGrey.withOpacity(0.4), () => _updateSelectedType('Thuốc trừ cỏ')),
                            _buildDrugItem("assets/virus.jpg", "Thuốc trừ bệnh", Colors.purple.withOpacity(0.6), () => _updateSelectedType('Thuốc trừ bệnh')),
                            _buildDrugItem("assets/chuot.png", "Thuốc trừ chuột", Colors.cyan.withOpacity(0.4), () => _updateSelectedType('Thuốc trừ chuột')),
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
                                  Expanded(
                                    child: Card(
                                      elevation: 6,
                                      color: Colors.green.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                           Icon(Icons.eco, size: 40, color: Colors.green),
                                            SizedBox(height: 8),
                                            Text(
                                              'Cây trồng',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Card(
                                      elevation: 6,
                                      color: Colors.blue.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.bug_report, size: 40, color: Colors.blue),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Dịch hại',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Số lượng hiện có
                      Text(
                        'Số lượng hiện có (${filteredDrugs.length})',
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // ListView chứa các Card thuốc hiển thị dạng lưới 2 cột
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredDrugs.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Số lượng cột (2 cột)
                          crossAxisSpacing: 16, // Khoảng cách giữa các cột
                          mainAxisSpacing: 16, // Khoảng cách giữa các hàng
                          childAspectRatio: 0.7, // Tỉ lệ chiều cao / chiều rộng của mỗi card
                        ),
                        itemBuilder: (context, index) {
                          final drug = filteredDrugs[index];
                          return _buildInfoCard(drug);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Hàm build Card thuốc
  Widget _buildInfoCard(Map<String, dynamic> drugInfo) {
    return GestureDetector(
      onTap: () {
        // Điều hướng tới trang chi tiết khi nhấn vào Card
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrugDetailPage(drugInfo: drugInfo), // Chuyển dữ liệu thuốc
          ),
        );
      },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 250, // Đặt chiều cao cố định (có thể điều chỉnh)
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Image.network(
                      drugInfo["imageUrl"] ?? 'https://example.com/default_image.png', // Sử dụng ảnh mặc định nếu không có
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    drugInfo["name"] ?? 'Tên thuốc không có',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đơn vị đăng ký thuốc: ',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    drugInfo['company'] ?? 'Công ty không có',
                    style: const TextStyle(fontSize: 14, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    drugInfo["type"] ?? 'Loại thuốc không có',
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildDrugItem(String imagePath, String drugName, Color avatarColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(imagePath),
              backgroundColor: avatarColor,
            ),
            const SizedBox(height: 8),
            Text(
              drugName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
