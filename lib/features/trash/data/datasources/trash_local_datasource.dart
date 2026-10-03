import '../../../../core/database/database.dart';
import '../models/trash_item_model.dart';

abstract class TrashLocalDataSource {
  Future<List<TrashItemModel>> getTrashedNotes();
  Future<void> restoreNote(String id);
  Future<void> deleteNotePermanently(String id);
  Future<void> emptyTrash();
}

class TrashLocalDataSourceImpl implements TrashLocalDataSource {
  final AppDatabase database;

  TrashLocalDataSourceImpl({required this.database});

  @override
  Future<List<TrashItemModel>> getTrashedNotes() async {
    final trashedNotes = await database.getTrashedNotes();
    return trashedNotes.map((n) => TrashItemModel.fromNote(n)).toList();
  }

  @override
  Future<void> restoreNote(String id) async {
    await database.restoreFromTrash(id);
  }

  @override
  Future<void> deleteNotePermanently(String id) async {
    await database.permanentlyDeleteFromTrash(id);
  }

  @override
  Future<void> emptyTrash() async {
    await database.emptyTrash();
  }
}
