import 'package:mynotes/features/notes/domain/entities/note.dart';

class TrashItem {
  final Note note;
  final String deletedAt;

  const TrashItem({
    required this.note,
    required this.deletedAt,
  });

  TrashItem copyWith({
    Note? note,
    String? deletedAt,
  }) {
    return TrashItem(
      note: note ?? this.note,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
