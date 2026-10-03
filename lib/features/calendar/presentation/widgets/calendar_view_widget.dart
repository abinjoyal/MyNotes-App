import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../notes/domain/entities/note.dart';
import 'calendar_event_marker.dart';

class CalendarViewWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final List<Note> allNotes;
  final List<Note> Function(DateTime day, List<Note> allNotes) eventLoader;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const CalendarViewWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.allNotes,
    required this.eventLoader,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final calendarBgColor = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: calendarBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAEAEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar<Note>(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          calendarFormat: calendarFormat,
          onDaySelected: onDaySelected,
          eventLoader: (day) => eventLoader(day, allNotes),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              return CalendarEventMarker(events: events);
            },
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: AppColors.primaryPurple,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(color: textColor),
            weekendTextStyle: TextStyle(color: textColor.withOpacity(0.7)),
            outsideTextStyle: TextStyle(color: textColor.withOpacity(0.3)),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            formatButtonVisible: false,
            leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
            rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: textColor),
            weekendStyle: TextStyle(color: textColor.withOpacity(0.7)),
          ),
        ),
      ),
    );
  }
}
