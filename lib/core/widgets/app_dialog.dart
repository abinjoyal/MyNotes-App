import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? content;
  final List<Widget>? actions;

  const AppDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.content,
    this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        subtitle: subtitle,
        icon: icon,
        content: content,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primaryPurple, size: 22),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6C757D),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (content != null) content!,
        ],
      ),
      actions: actions,
    );
  }
}
