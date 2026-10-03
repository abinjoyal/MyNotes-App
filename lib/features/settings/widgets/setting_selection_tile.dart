import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';

class SettingSelectionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String currentValue;
  final List<String> options;
  final Color textColor;
  final Color secondaryTextColor;
  final Color dropdownBg;
  final ValueChanged<String> onChanged;

  const SettingSelectionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.currentValue,
    required this.options,
    required this.textColor,
    required this.secondaryTextColor,
    required this.dropdownBg,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: dropdownBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                dropdownColor: dropdownBg,
                isDense: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryPurple),
                items: options.map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text(opt),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onChanged(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
