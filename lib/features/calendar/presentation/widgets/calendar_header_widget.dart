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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar',
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
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Today Quick Jump Button (Height: 38, Radius: 10)
            SizedBox(
              height: 38,
              child: OutlinedButton.icon(
                onPressed: onTodayTap,
                icon: const Icon(
                  Icons.today_rounded,
                  size: 16,
                  color: AppColors.primaryPurple,
                ),
                label: const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.primaryPurple.withOpacity(0.5),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Month / Week Format Toggle Pill (Height: 38, Radius: 10)
            Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF262634)
                    : const Color(0xFFEAEAEE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF363646)
                      : const Color(0xFFD8D8E0),
                ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}
