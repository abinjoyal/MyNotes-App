import '../../domain/entities/trash_item.dart';
import '../../domain/repositories/trash_repository.dart';
import '../datasources/trash_local_datasource.dart';
import '../../../../core/database/database.dart';

class TrashRepositoryImpl implements TrashRepository {
  final TrashLocalDataSource localDataSource;

  TrashRepositoryImpl([AppDatabase? db])
    : localDataSource = TrashLocalDataSourceImpl(
        database: db ?? AppDatabase.instance,
      );

  TrashRepositoryImpl.withDataSource(this.localDataSource);

  @override
  Future<List<TrashItem>> getTrashItems() async {
    return await localDataSource.getTrashedNotes();
  }

  @override
  Future<void> restoreNote(String id) async {
    await localDataSource.restoreNote(id);
  }

  @override
  Future<void> deleteNotePermanently(String id) async {
    await localDataSource.deleteNotePermanently(id);
  }

  @override
  Future<void> emptyTrash() async {
    await localDataSource.emptyTrash();
  }
}
