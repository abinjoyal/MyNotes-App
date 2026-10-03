import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_datasource.dart';
import '../models/calendar_event_model.dart';
import '../../../notes/domain/entities/note.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDataSource localDataSource;

  CalendarRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    return await localDataSource.getEventsForDate(date);
  }

  @override
  Future<List<CalendarEvent>> getEventsForRange(DateTime start, DateTime end) async {
    return await localDataSource.getEventsForRange(start, end);
  }

  @override
  CalendarEvent createEventFromNote(Note note) {
    return CalendarEventModel.fromNote(note);
  }
}
