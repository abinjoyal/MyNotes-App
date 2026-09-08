import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';

class NotesSearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool isDark;

  const NotesSearchBarWidget({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final inputBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FA);
    final borderColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAEAEE);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: inputBg.withOpacity(isDark ? 0.6 : 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.lightText,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    style: TextStyle(fontSize: 14, color: textColor),
                    decoration: const InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A30) : const Color(0xFFEAEAEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '⌘K',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: inputBg.withOpacity(isDark ? 0.6 : 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: textColor,
              size: 20,
            ),
            onPressed: onFilterTap,
          ),
        ),
      ],
    );
  }
}

class NotesLayoutControlsWidget extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onSortChanged;
  final bool isGridView;
  final ValueChanged<bool> onLayoutChanged;
  final bool isDark;

  const NotesLayoutControlsWidget({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
    required this.isGridView,
    required this.onLayoutChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final inputBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FA);
    final borderColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAEAEE);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PopupMenuButton<String>(
          onSelected: onSortChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort by: ',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.lightText,
                ),
              ),
              Text(
                selectedSort,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: textColor,
              ),
            ],
          ),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'Last edited',
              child: Text('Last edited'),
            ),
            PopupMenuItem(
              value: 'Title',
              child: Text('Title'),
            ),
            PopupMenuItem(
              value: 'Date created',
              child: Text('Date created'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onLayoutChanged(false),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: !isGridView
                        ? AppColors.lightLavender
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.format_list_bulleted_rounded,
                    size: 18,
                    color: !isGridView
                        ? AppColors.primaryPurple
                        : AppColors.lightText,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => onLayoutChanged(true),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isGridView
                        ? AppColors.lightLavender
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    size: 18,
                    color: isGridView
                        ? AppColors.primaryPurple
                        : AppColors.lightText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
