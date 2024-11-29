import 'package:flutter/material.dart';
import 'package:weather/Components/color.dart';
class CustomDropdown extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final String? Function(String?)? validator;
  final void Function(String?) onChanged;

  const CustomDropdown({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.items,
    this.selectedValue,
    this.validator,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(icon, color: blackColor.withOpacity(.3)),
          const SizedBox(width: 10.0),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 10.0),
                ),
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: blackColor),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                validator: validator,
              ),

            ),
          ),
        ],
      ),
    );
  }
}
