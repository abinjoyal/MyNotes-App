import '../entities/trash_item.dart';

abstract class TrashRepository {
  Future<List<TrashItem>> getTrashItems();
  Future<void> restoreNote(String id);
  Future<void> deleteNotePermanently(String id);
  Future<void> emptyTrash();
}
