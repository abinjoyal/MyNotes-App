import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../notes/domain/entities/note.dart';

class CalendarState {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;

  const CalendarState({
    required this.focusedDay,
    required this.selectedDay,
    this.calendarFormat = CalendarFormat.month,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    CalendarFormat? calendarFormat,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
    );
  }
}

class CalendarController extends ChangeNotifier {
  CalendarState _state = CalendarState(
    focusedDay: DateTime.now(),
    selectedDay: DateTime.now(),
  );

  CalendarState get state => _state;
  DateTime get focusedDay => _state.focusedDay;
  DateTime get selectedDay => _state.selectedDay;
  CalendarFormat get calendarFormat => _state.calendarFormat;

  void setSelectedDay(DateTime selectedDay, DateTime focusedDay) {
    _state = _state.copyWith(
      selectedDay: selectedDay,
      focusedDay: focusedDay,
    );
    notifyListeners();
  }

  void setCalendarFormat(CalendarFormat format) {
    _state = _state.copyWith(calendarFormat: format);
    notifyListeners();
  }

  void jumpToToday() {
    final now = DateTime.now();
    _state = _state.copyWith(
      selectedDay: now,
      focusedDay: now,
    );
    notifyListeners();
  }

  DateTime? parseNoteDate(Note note) {
    try {
      final ms = int.tryParse(note.id);
      if (ms != null) {
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    } catch (_) {}
    return null;
  }

  bool isSameCalendarDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Note> getEventsForDay(DateTime day, List<Note> allNotes) {
    return allNotes.where((note) {
      final date = parseNoteDate(note);
      return isSameCalendarDay(date, day);
    }).toList();
  }
}
