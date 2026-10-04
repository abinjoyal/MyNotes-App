import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/theme/app_theme_colors.dart';

class TasksHeaderBar extends StatelessWidget {
  final int totalChecklistsCount;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final bool isGridView;
  final ValueChanged<bool> onToggleViewMode;
  final bool isTimerRunning;
  final bool showFocusTimerCard;
  final int timerRemainingSeconds;
  final VoidCallback onToggleFocusTimer;
  final VoidCallback onCreateChecklist;
  final String Function(int seconds) formatTimerTime;

  const TasksHeaderBar({
    super.key,
    required this.totalChecklistsCount,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.isGridView,
    required this.onToggleViewMode,
    required this.isTimerRunning,
    required this.showFocusTimerCard,
    required this.timerRemainingSeconds,
    required this.onToggleFocusTimer,
    required this.onCreateChecklist,
    required this.formatTimerTime,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = colors.isDark;
    final textColor = colors.textColor;
    final borderColor = colors.borderColor;
    final inputBg = isDark ? const Color(0xFF262630) : const Color(0xFFF7F8FA);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Tasks Checklist',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Input
            Container(
              width: 200,
              height: 38,
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: TextStyle(fontSize: 13, color: textColor),
                decoration: const InputDecoration(
                  hintText: 'Search checklists ...',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF8C98A9)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Color(0xFF8C98A9),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // List / Grid View Toggle
            Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => onToggleViewMode(false),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !isGridView
                            ? (isDark
                                  ? AppColors.primaryPurple.withOpacity(0.3)
                                  : AppColors.lightLavender)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        Icons.format_list_bulleted_rounded,
                        size: 18,
                        color: !isGridView
                            ? AppColors.primaryPurple
                            : const Color(0xFF8C98A9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  GestureDetector(
                    onTap: () => onToggleViewMode(true),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isGridView
                            ? (isDark
                                  ? AppColors.primaryPurple.withOpacity(0.3)
                                  : AppColors.lightLavender)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 18,
                        color: isGridView
                            ? AppColors.primaryPurple
                            : const Color(0xFF8C98A9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Focus Timer Button
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: onToggleFocusTimer,
                icon: Icon(
                  isTimerRunning
                      ? Icons.timer_rounded
                      : (showFocusTimerCard
                            ? Icons.timer_rounded
                            : Icons.timer_outlined),
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  isTimerRunning
                      ? '⏱️ ${formatTimerTime(timerRemainingSeconds)}'
                      : 'Focus Timer',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTimerRunning
                      ? const Color(0xFFFFB020)
                      : (showFocusTimerCard
                            ? const Color(0xFF635BFF)
                            : const Color(0xFF2C2C38)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Create Task Checklist Button
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: onCreateChecklist,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Create Task Checklist',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
