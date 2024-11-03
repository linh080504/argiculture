import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';

class IntroductionLetter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giới thiệu về MobiAgri'),
        backgroundColor: primaryColor,
      ),
      body: ListView( // Sử dụng ListView thay vì Column
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Kính gửi Quý Nông Dân và Người Làm Nghề Nông,',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 16),
          Text(
            'Chúng tôi rất vui mừng giới thiệu đến các bạn ứng dụng MobiAgri, một công cụ hỗ trợ đắc lực cho những người làm trong ngành nông nghiệp. Với MobiAgri, chúng tôi mong muốn mang lại sự tiện lợi và hiệu quả trong việc quản lý cây trồng, cũng như nâng cao chất lượng sản phẩm nông nghiệp.',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Text(
            'MobiAgri cung cấp những tính năng nổi bật như:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '• Tra cứu thông tin thuốc nông nghiệp một cách dễ dàng.',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            '• Quản lý và theo dõi quy trình chăm sóc cây trồng.',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            '• Kết nối cộng đồng nông nghiệp để chia sẻ kinh nghiệm và kiến thức.',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            '• Cập nhật tin tức và thông tin mới nhất về nông nghiệp.',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Text(
            'mobiAgri là nền tảng trong Hệ sinh thái Nông nghiệp cùng hợp tác và phát triển. Với mong muốn tạo ra những giá trị hữu ích cho cộng đồng, chúng tôi luôn nỗ lực không ngừng để nâng cấp, cải tiến và cho ra đời những tính năng hấp dẫn hơn trong thời gian sắp tới.',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Text(
            'Chúng tôi tin rằng MobiAgri sẽ giúp các bạn tiết kiệm thời gian và công sức, từ đó nâng cao hiệu quả sản xuất và chất lượng sản phẩm. Hãy cùng chúng tôi tham gia vào hành trình phát triển nông nghiệp bền vững!',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Text(
            'Trân trọng,',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Đội ngũ phát triển MobiAgri',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
