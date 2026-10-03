import '../../domain/entities/calendar_event.dart';
import '../../../notes/domain/entities/note.dart';

class CalendarEventModel extends CalendarEvent {
  const CalendarEventModel({
    required super.id,
    required super.title,
    required super.date,
    required super.color,
    required super.note,
  });

  factory CalendarEventModel.fromNote(Note note) {
    DateTime date = DateTime.now();
    try {
      final ms = int.tryParse(note.id);
      if (ms != null) {
        date = DateTime.fromMillisecondsSinceEpoch(ms);
      }
    } catch (_) {}

    return CalendarEventModel(
      id: note.id,
      title: note.title.isEmpty ? 'Untitled Note' : note.title,
      date: date,
      color: note.indicatorColor,
      note: note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'color': color.value,
      'noteId': note.id,
    };
  }
}
