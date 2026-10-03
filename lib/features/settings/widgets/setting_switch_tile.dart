import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';

class SettingSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final Color textColor;
  final Color secondaryTextColor;
  final ValueChanged<bool> onChanged;

  const SettingSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: secondaryTextColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
