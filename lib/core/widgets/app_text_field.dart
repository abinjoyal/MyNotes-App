import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final int? maxLines;
  final bool autoFocus;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FA);
    final borderColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAEAEE);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;

    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        obscureText: obscureText,
        maxLines: maxLines,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF8C98A9),
            fontSize: 14,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}
