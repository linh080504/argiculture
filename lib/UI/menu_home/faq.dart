import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';

class FAQ extends StatefulWidget {
  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  late List<bool> _isExpanded;

  final List<Map<String, String>> _faqs = [
    {
      "question": "1. MobiAgri là gì?",
      "answer": "MobiAgri là ứng dụng hỗ trợ nông dân trong việc quản lý cây trồng và cung cấp thông tin nông nghiệp."
    },
    {
      "question": "2. Làm thế nào để đăng ký tài khoản?",
      "answer": "Bạn có thể đăng ký tài khoản bằng cách vào phần Đăng ký và điền thông tin cần thiết."
    },
    {
      "question": "3. Ứng dụng có miễn phí không?",
      "answer": "Ứng dụng MobiAgri hoàn toàn miễn phí cho người dùng."
    },
    {
      "question": "4. Làm thế nào để liên hệ với chúng tôi?",
      "answer": "Bạn có thể liên hệ với chúng tôi qua email: support@mobiagri.com."
    },
    {
      "question": "5. Làm thế nào để đăng xuất khỏi tài khoản đang sử dụng",
      "answer": "Để đăng xuất khỏi tài khoản đang sử dụng, Bạn truy cập vào mục Tôi ở Menu chính và chạm nút Đăng xuất "
    },
    {
      "question": "6. MobiAgri có tính năng nào giúp nông dân kết nối với nhau không?",
      "answer": "Có, ứng dụng cung cấp tính năng kết nối để nông dân có thể chia sẻ kinh nghiệm và kiến thức với nhau."
    },
    {
      "question": "7. Ai có thể sử dụng MobiAgri?",
      "answer": "MobiAgri được thiết kế cho mọi người làm trong ngành nông nghiệp, bao gồm nông dân, nhà khoa học, và những ai quan tâm đến nông nghiệp."
    },
    {
      "question": "8. MobiAgri có cung cấp thông tin thời tiết không?",
      "answer": "Có, ứng dụng sẽ cung cấp thông tin thời tiết hiện tại và dự báo thời tiết cho khu vực bạn đang ở."
    },
    {
      "question": "9. Có cách nào để khôi phục mật khẩu không?",
      "answer": "Có, bạn có thể sử dụng chức năng quên mật khẩu trên màn hình đăng nhập để khôi phục tài khoản của mình."
    },
    {
      "question": "10. Có thể sử dụng MobiAgri trên nhiều thiết bị không?",
      "answer": "Có, bạn có thể đăng nhập tài khoản của mình trên nhiều thiết bị khác nhau."
    },
    // Thêm nhiều câu hỏi khác nếu cần
  ];

  @override
  void initState() {
    super.initState();
    _isExpanded = List.generate(_faqs.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Câu Hỏi Thường Gặp'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _faqs.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      _faqs[index]["question"] ?? '', // Sử dụng ?? để đảm bảo không null
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(
                      _isExpanded[index] ? Icons.expand_less : Icons.expand_more,
                    ),
                    onTap: () {
                      setState(() {
                        _isExpanded[index] = !_isExpanded[index];
                      });
                    },
                  ),
                  if (_isExpanded[index]) // Hiển thị nội dung khi được mở
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _faqs[index]["answer"] ?? '', // Sử dụng ?? để đảm bảo không null
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
