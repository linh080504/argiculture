import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';

class TermsOfUse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Điều Khoản Sử Dụng'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Điều Khoản Sử Dụng',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Chào mừng bạn đến với ứng dụng MobiAgri. Việc sử dụng ứng dụng này đồng nghĩa với việc bạn đồng ý với các điều khoản và điều kiện dưới đây. Nếu bạn không đồng ý, xin vui lòng ngừng sử dụng ứng dụng.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('1. Giới thiệu'),
            SizedBox(height: 8),
            _buildSectionContent(
                'MobiAgri là ứng dụng cung cấp thông tin và công cụ hỗ trợ cho nông dân và những người làm trong ngành nông nghiệp. Chúng tôi cam kết cung cấp dịch vụ tốt nhất cho người dùng.'
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('2. Điều kiện sử dụng'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Bạn đồng ý sử dụng ứng dụng này chỉ cho các mục đích hợp pháp và không vi phạm bất kỳ quy định nào của pháp luật hiện hành.'
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('3. Quyền và nghĩa vụ của người dùng'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Người dùng có quyền:\n'
                    '• Truy cập và sử dụng các tính năng của ứng dụng.\n'
                    '• Đưa ra phản hồi và yêu cầu hỗ trợ từ đội ngũ phát triển.\n'
                    'Người dùng có nghĩa vụ:\n'
                    '• Cung cấp thông tin chính xác và đầy đủ khi đăng ký tài khoản.\n'
                    '• Bảo mật thông tin tài khoản của mình.'
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('4. Bảo mật thông tin'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Chúng tôi cam kết bảo vệ thông tin cá nhân của người dùng. Vui lòng tham khảo Chính Sách Bảo Mật để biết thêm chi tiết.'
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('5. Thay đổi điều khoản sử dụng'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Chúng tôi có quyền cập nhật hoặc thay đổi các điều khoản sử dụng này. Mọi thay đổi sẽ có hiệu lực ngay khi được đăng tải trên ứng dụng.'
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle('6. Liên hệ'),
            SizedBox(height: 8),
            _buildSectionContent(
                'Nếu bạn có bất kỳ câu hỏi nào về các điều khoản sử dụng này, vui lòng liên hệ với chúng tôi qua địa chỉ email: support@mobiagri.com'
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
}
