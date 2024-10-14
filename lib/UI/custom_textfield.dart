import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';

class CustomTextfield extends StatelessWidget {
  final IconData icon;
  final bool obscureText;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator; // Sửa kiểu dữ liệu của validator

  const CustomTextfield({
    super.key,
    required this.icon,
    required this.obscureText,
    required this.hintText,
    this.controller,
    required this.validator, // Đưa validator vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Thêm controller vào TextFormField
      obscureText: obscureText,
      style: TextStyle(color: blackColor),
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(icon, color: blackColor.withOpacity(.3)),
        hintText: hintText,
      ),
      cursorColor: blackColor.withOpacity(.5),
      validator: validator, // Thêm validator vào đây
    );
  }
}
