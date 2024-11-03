import 'dart:ui';
import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.lightBlueAccent.withOpacity(0.1);
    Path path = Path();

    // Bắt đầu từ phía dưới bên trái
    path.moveTo(0, size.height * 0.7); // Bắt đầu từ 2/3 phía dưới màn hình

    // Vẽ đường uống lượn lần 1 (đi lên)
    path.quadraticBezierTo(
        size.width * 0.25, // Điểm kiểm soát ở giữa 1/4 chiều rộng màn hình
        size.height * 0.5, // Đỉnh của đường cong đầu tiên
        size.width * 0.5,  // Điểm kết thúc của lần 1
        size.height * 0.7  // Xuống lại tới 70% chiều cao
    );

    // Vẽ đường uống lượn lần 2 (đi xuống rồi lên lại)
    path.quadraticBezierTo(
        size.width * 0.75, // Điểm kiểm soát ở giữa 3/4 chiều rộng màn hình
        size.height * 0.9, // Đáy của đường cong thứ hai
        size.width,        // Kết thúc ở phía phải màn hình
        size.height * 0.7  // Kết thúc lại ở 70% chiều cao
    );

    // Đi xuống và đóng đường (đi tới đáy màn hình)
    path.lineTo(size.width, size.height); // Vẽ đường thẳng xuống đáy bên phải
    path.lineTo(0, size.height);          // Vẽ đường thẳng qua đáy bên trái
    path.close();                         // Đóng đường Path

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
