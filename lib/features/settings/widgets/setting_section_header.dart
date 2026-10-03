import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';

class SettingSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color textColor;

  const SettingSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryPurple),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
