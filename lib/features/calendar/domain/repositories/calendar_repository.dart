import '../entities/calendar_event.dart';
import '../../../notes/domain/entities/note.dart';

abstract class CalendarRepository {
  Future<List<CalendarEvent>> getEventsForDate(DateTime date);
  Future<List<CalendarEvent>> getEventsForRange(DateTime start, DateTime end);
  CalendarEvent createEventFromNote(Note note);
}
