import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';
import 'package:weather/UI/DrugsPage/build_allowed_drug_content.dart';

class DrugLookPage extends StatefulWidget {
  const DrugLookPage({super.key});

  @override
  State<DrugLookPage> createState() => _DrugLookPageState();
}

class _DrugLookPageState extends State<DrugLookPage> {
  bool _isAllowedDrugExpanded = false;
  bool _isBannedDrugExpanded = false;
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tra cứu thuốc',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightGreen.shade200,
        iconTheme: IconThemeData(color: Colors.green.shade800),
        elevation: 4,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services, color: Colors.green),
                label: 'Thuốc được sử dụng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.block, color: Colors.red),
                label: 'Thuốc cấm sử dụng',
              ),
            ],
            currentIndex: _bottomNavIndex,
            selectedItemColor: Colors.green.shade800,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            onTap: (index) {
              setState(() {
                _bottomNavIndex = index;
              });
            },
          ),
        ),
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          AllowedDrugContent(),
          _buildBannedDrugContent(),
        ],
      ),
    );
  }

  Widget _buildBannedDrugContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isBannedDrugExpanded = !_isBannedDrugExpanded;
                if (_isAllowedDrugExpanded) {
                  _isAllowedDrugExpanded = false;
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade100,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Thuốc cấm sử dụng",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  Icon(
                    _isBannedDrugExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
          if (_isBannedDrugExpanded) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Danh sách các thuốc cấm sử dụng:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text("- Thuốc D", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text("- Thuốc E", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text("- Thuốc F", style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
