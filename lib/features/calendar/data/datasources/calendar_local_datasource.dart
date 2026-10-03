import '../../../../core/database/database.dart';
import '../models/calendar_event_model.dart';

abstract class CalendarLocalDataSource {
  Future<List<CalendarEventModel>> getEventsForDate(DateTime date);
  Future<List<CalendarEventModel>> getEventsForRange(
    DateTime start,
    DateTime end,
  );
}

class CalendarLocalDataSourceImpl implements CalendarLocalDataSource {
  final AppDatabase database;

  CalendarLocalDataSourceImpl({required this.database});

  @override
  Future<List<CalendarEventModel>> getEventsForDate(DateTime date) async {
    final notes = await database.getAllNotes();
    return notes
        .map((n) => CalendarEventModel.fromNote(n))
        .where(
          (event) =>
              event.date.year == date.year &&
              event.date.month == date.month &&
              event.date.day == date.day,
        )
        .toList();
  }

  @override
  Future<List<CalendarEventModel>> getEventsForRange(
    DateTime start,
    DateTime end,
  ) async {
    final notes = await database.getAllNotes();
    return notes
        .map((n) => CalendarEventModel.fromNote(n))
        .where(
          (event) =>
              event.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              event.date.isBefore(end.add(const Duration(seconds: 1))),
        )
        .toList();
  }
}
