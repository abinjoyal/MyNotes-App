import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../app/constants/app_colors.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final CalendarFormat calendarFormat;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final VoidCallback onTodayTap;

  const CalendarHeaderWidget({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.calendarFormat,
    required this.onFormatChanged,
    required this.onTodayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 Calendar',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'View & manage notes linked to dates',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF8C98A9)
                    : const Color(0xFF6C757D),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Today Quick Jump Chip
            OutlinedButton.icon(
              onPressed: onTodayTap,
              icon: const Icon(
                Icons.today_rounded,
                size: 14,
                color: AppColors.primaryPurple,
              ),
              label: const Text(
                'Today',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primaryPurple.withOpacity(0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Month / Week Format Toggle Pill
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF262634)
                    : const Color(0xFFEAEAEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildFormatOption('Month', CalendarFormat.month),
                  _buildFormatOption('Week', CalendarFormat.week),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatOption(String label, CalendarFormat format) {
    final isSelected = calendarFormat == format;
    return GestureDetector(
      onTap: () => onFormatChanged(format),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}
