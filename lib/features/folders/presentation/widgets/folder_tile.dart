import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../domain/entities/folder.dart';

class FolderTile extends StatelessWidget {
  final Folder folder;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onAddNote;

  const FolderTile({
    super.key,
    required this.folder,
    required this.count,
    required this.onTap,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF232329) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.darkText;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFEAEAEE);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: folder.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_rounded,
                    color: folder.color,
                    size: 22,
                  ),
                ),
                IconButton(
                  tooltip: 'Add note to ${folder.name}',
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 20,
                    color: AppColors.primaryPurple,
                  ),
                  onPressed: onAddNote,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count ${count == 1 ? 'note' : 'notes'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8C98A9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
