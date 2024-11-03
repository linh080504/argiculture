import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';

class Partners extends StatelessWidget {
  final List<Map<String, String>> partners = [
    {
      "logo": "assets/logo_1.png",
      "name": "Công ty VAEC",
      "description": "Công ty VAEC chuyên cung cấp sản phẩm nông nghiệp chất lượng cao."
    },
    {
      "logo": "assets/logo_2.jpg",
      "name": "Công ty C.P.Group",
      "description": "Công ty C.P.Group là đối tác lâu năm trong lĩnh vực phát triển công nghệ nông nghiệp."
    },
    {
      "logo": "assets/logo_1.png",
      "name": "Công ty C",
      "description": "Công ty C cung cấp giải pháp thông minh cho ngành nông nghiệp."
    },
    {
      "logo": "assets/logo_2.jpg",
      "name": "Công ty D",
      "description": "Công ty D nổi bật với sản phẩm hữu cơ và thân thiện với môi trường."
    },
    // Thêm nhiều công ty khác nếu cần
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đối Tác Của Chúng Tôi'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: partners.map((partner) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Cột 1: Logo công ty
                    Image.asset(
                      partner["logo"]!,
                      height: 60, // Chiều cao logo
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 16), // Khoảng cách giữa logo và tên công ty
                    // Cột 2: Tên và giới thiệu công ty
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partner["name"]!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4), // Khoảng cách giữa tên và giới thiệu
                          Text(
                            partner["description"]!,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16), // Khoảng cách giữa các đối tác
                Divider(), // Dấu gạch ngang phân cách
                SizedBox(height: 16), // Khoảng cách sau dấu gạch
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
