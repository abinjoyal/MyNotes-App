import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';

class NotesHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final int noteCount;
  final Color textColor;
  final String activeRoute;
  final VoidCallback onEmptyTrash;

  const NotesHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.noteCount,
    required this.textColor,
    required this.activeRoute,
    required this.onEmptyTrash,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lightLavender,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$noteCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        if (activeRoute == 'trash' && noteCount > 0)
          ElevatedButton.icon(
            onPressed: onEmptyTrash,
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: const Text('Empty Trash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
      ],
    );
  }
}
