import 'package:mynotes/core/database/database.dart';
import 'package:mynotes/features/trash/domain/entities/trash_item.dart';
import 'package:mynotes/features/trash/domain/repositories/trash_repository.dart';

class TrashRepositoryImpl implements TrashRepository {
  final AppDatabase _database;

  TrashRepositoryImpl(this._database);

  @override
  Future<List<TrashItem>> getTrashItems() async {
    final notes = await _database.getTrashedNotes();
    
    return notes.map((note) {
      return TrashItem(
        note: note,
        // Since DB doesn't have a deletedAt field, we fallback to updatedAt
        deletedAt: note.updatedAt, 
      );
    }).toList();
  }

  @override
  Future<void> restoreNote(String id) async {
    await _database.restoreFromTrash(id);
  }

  @override
  Future<void> deleteNotePermanently(String id) async {
    await _database.permanentlyDeleteFromTrash(id);
  }

  @override
  Future<void> emptyTrash() async {
    await _database.emptyTrash();
  }
}
