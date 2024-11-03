import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chính Sách Bảo Mật'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Chính Sách Bảo Mật',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Chúng tôi tại MobiAgri cam kết bảo vệ quyền riêng tư của người dùng. Chính sách bảo mật này mô tả cách chúng tôi thu thập, sử dụng, và bảo vệ thông tin cá nhân của bạn khi sử dụng ứng dụng MobiAgri.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            Divider(), // Ngăn cách giữa các phần
            SizedBox(height: 16),

            _buildSectionTitle('1. Thông tin chúng tôi thu thập'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Chúng tôi có thể thu thập thông tin cá nhân bao gồm nhưng không giới hạn: tên, địa chỉ email, số điện thoại, và thông tin liên quan đến hoạt động sử dụng ứng dụng của bạn.'
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('2. Cách chúng tôi sử dụng thông tin'),
            SizedBox(height: 8),
            _buildSectionContent(
              'Thông tin của bạn có thể được sử dụng để:',
            ),
            SizedBox(height: 8),
            _buildBulletPoint('• Cung cấp, duy trì và cải thiện dịch vụ của chúng tôi.'),
            _buildBulletPoint('• Gửi thông tin cập nhật và thông báo.'),
            _buildBulletPoint('• Phân tích và hiểu rõ hơn về nhu cầu của người dùng.'),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('3. Bảo mật thông tin'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Chúng tôi thực hiện các biện pháp bảo mật hợp lý để bảo vệ thông tin cá nhân của bạn khỏi việc truy cập trái phép, sử dụng hoặc tiết lộ.'
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('4. Chia sẻ thông tin'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Chúng tôi không bán, giao dịch hoặc cho thuê thông tin cá nhân của bạn cho bên thứ ba mà không có sự đồng ý của bạn, ngoại trừ trường hợp pháp luật yêu cầu.'
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('5. Thay đổi chính sách'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Chúng tôi có quyền cập nhật chính sách bảo mật này. Mọi thay đổi sẽ được thông báo trên ứng dụng và có hiệu lực ngay khi được đăng tải.'
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('Liên hệ'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Nếu bạn có bất kỳ câu hỏi nào về chính sách bảo mật này, vui lòng liên hệ với chúng tôi qua địa chỉ email: support@mobiagri.com'
            ),
            SizedBox(height: 16),
            _buildSectionContent(
              'Cảm ơn bạn đã sử dụng MobiAgri!',
              italic: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildSectionContent(String content, {bool italic = false}) {
    return Text(
      content,
      style: TextStyle(fontSize: 18, fontStyle: italic ? FontStyle.italic : FontStyle.normal),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildBulletPoint(String point) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        point,
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
