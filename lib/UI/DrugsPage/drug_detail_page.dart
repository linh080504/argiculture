import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firebase Firestore
import 'package:weather/Components/color.dart';

class DrugDetailPage extends StatelessWidget {
  final Map<String, dynamic> drugInfo;

  const DrugDetailPage({required this.drugInfo});

  // Lấy dữ liệu về thuốc tương tự từ Firestore (hoặc bất kỳ nguồn dữ liệu nào khác)
  Future<List<Map<String, dynamic>>> fetchSimilarDrugs(String currentDrugType) async {
    try {
      // Lấy dữ liệu từ Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('drugs').get();
      print('Total drugs fetched: ${snapshot.docs.length}'); // Kiểm tra số lượng docs trả về từ Firestore

      // Lọc các thuốc có cùng loại với loại thuốc hiện tại
      List<Map<String, dynamic>> drugsList = snapshot.docs
          .map((doc) {
        return {
          "name": doc['name'],
          "company": doc['company'],
          "imageUrl": doc['imageUrl'],
          "type": doc['type'],
        };
      })
          .toList();

      // In danh sách thuốc trước khi lọc
      print("Drugs before filtering by type: ${drugsList.map((drug) => drug['name']).toList()}");

      // Lọc các thuốc cùng loại với currentDrugType, sử dụng toLowerCase để so sánh
      List<Map<String, dynamic>> filteredDrugs = drugsList.where((drug) => drug['type'].toLowerCase() == currentDrugType.toLowerCase()).toList();
      print("Fetched drugs matching type: ${filteredDrugs.length}"); // Kiểm tra số lượng thuốc matching type

      // In danh sách thuốc cùng loại
      print("Drugs matching current drug type: ${filteredDrugs.map((drug) => drug['name']).toList()}");

      // Loại bỏ thuốc hiện tại (tự động bỏ thuốc hiện tại nếu tên trùng với drugInfo['name'])
      print("Removing drug: ${drugInfo['name']}");
      filteredDrugs.removeWhere((drug) => drug['name'] == drugInfo['name']);
      print("Drugs after removal: ${filteredDrugs.length}"); // Kiểm tra danh sách sau khi loại bỏ thuốc hiện tại

      return filteredDrugs;
    } catch (e) {
      print("Error fetching drugs: $e");
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          drugInfo["name"] ?? 'Tên thuốc không có',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh thuốc
            _buildDrugImageCard(),
            // Card 1: Tên thuốc, Công ty sản xuất, Loại thuốc
            _buildDrugInfoCard(),
            // Card 2: Hoạt chất, Hàm lượng, Dạng thuốc
            _buildDrugDetailsCard(),
            // Card 3: Công dụng
            _buildDrugUsageCard(),
            // Card 4: Cảnh báo
            _buildDrugWarningsCard(),
            // Card 5: Khuyến nghị an toàn
            _buildSafetyRecommendationCard(),
            // Card Sản phẩm tương tự
            _buildSimilarDrugsList(),
          ],
        ),
      ),
    );
  }

  // Card Ảnh thuốc
  Widget _buildDrugImageCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Image.network(
            drugInfo["imageUrl"] ?? 'https://example.com/default_image.png',
            height: 250,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Card 1: Tên thuốc, Công ty sản xuất, Loại thuốc
  Widget _buildDrugInfoCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  drugInfo["name"] ?? 'Không có thông tin',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                Text(
                  drugInfo["type"] ?? 'Không có thông tin',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              drugInfo["company"] ?? 'Không có thông tin',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  // Card 2: Hoạt chất, Hàm lượng, Dạng thuốc
  Widget _buildDrugDetailsCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Hoạt chất', drugInfo["activeIngredient"] ?? 'Không có thông tin'),
            _buildDetailRow('Hàm lượng', drugInfo["dosage"] ?? 'Không có thông tin'),
            _buildDetailRow('Dạng thuốc', drugInfo["form"] ?? 'Không có thông tin'),
          ],
        ),
      ),
    );
  }

  // Card 3: Công dụng
  Widget _buildDrugUsageCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      color: Colors.white,
      child: Container(
        width: double.infinity, // Đặt chiều rộng của Card bằng chiều rộng màn hình
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Công dụng',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              drugInfo["usage"] ?? 'Không có thông tin',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Card 4: Cảnh báo
  Widget _buildDrugWarningsCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      color: Colors.white,
      child: Container(
        width: double.infinity, // Đặt chiều rộng của Card bằng chiều rộng màn hình
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cảnh báo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              drugInfo["warnings"] ?? 'Không có thông tin',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }


  // Card 5: Khuyến nghị an toàn
  Widget _buildSafetyRecommendationCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khuyến nghị an toàn',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: Image.asset(
                'assets/khuyen_nghi.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo hàng thông tin chi tiết
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // Card Sản phẩm tương tự
  Widget _buildSimilarDrugsList() {
    // Lấy loại thuốc hiện tại từ thông tin thuốc
    String currentDrugType = drugInfo["type"] ?? '';

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchSimilarDrugs(currentDrugType),  // Truyền loại thuốc vào
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Có lỗi xảy ra khi tải thuốc tương tự."));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Không có thuốc tương tự."));
        }

        List<Map<String, dynamic>> similarDrugs = snapshot.data!;

        // Loại bỏ thuốc hiện tại khỏi danh sách
        similarDrugs.removeWhere((drug) => drug["name"] == drugInfo["name"]);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị tiêu đề "Sản phẩm tương tự" ở ngoài SingleChildScrollView
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Sản phẩm tương tự',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // Danh sách thuốc tương tự
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: similarDrugs.map((drug) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Điều hướng đến trang drug_detail_page và truyền thông tin thuốc
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DrugDetailPage(drugInfo: drug), // Sửa lại tên tham số thành 'drugInfo'
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
                              height: 250, // Chiều cao cố định cho mỗi Card
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Hiển thị ảnh thuốc
                                  Expanded(
                                    child: Image.network(
                                      drug["imageUrl"] ?? 'https://example.com/default_image.png',
                                      height: 110,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Hiển thị tên thuốc
                                  Text(
                                    drug["name"] ?? 'Tên thuốc không có',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  // Hiển thị công ty
                                  Text(
                                    'Công ty: ${drug['company'] ?? 'Không có'}',
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  // Hiển thị loại thuốc
                                  Text(
                                    drug["type"] ?? 'Loại thuốc không có',
                                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



}
