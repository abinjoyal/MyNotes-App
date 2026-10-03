import '../../domain/entities/trash_item.dart';
import '../../../notes/domain/entities/note.dart';

class TrashItemModel extends TrashItem {
  const TrashItemModel({required super.note, required super.deletedAt});

  factory TrashItemModel.fromNote(Note note) {
    return TrashItemModel(note: note, deletedAt: note.updatedAt);
  }

  Map<String, dynamic> toMap() {
    return {'noteId': note.id, 'title': note.title, 'deletedAt': deletedAt};
  }
}
