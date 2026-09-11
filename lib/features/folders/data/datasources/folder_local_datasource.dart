import '../../../../core/database/database.dart';
import '../models/folder_model.dart';

abstract class FolderLocalDataSource {
  Future<List<FolderModel>> getAllFolders();
  Future<void> saveFolder(FolderModel folder);
  Future<void> deleteFolder(String name);
}

class FolderLocalDataSourceImpl implements FolderLocalDataSource {
  final AppDatabase database;

  FolderLocalDataSourceImpl({required this.database});

  @override
  Future<List<FolderModel>> getAllFolders() async {
    return await database.getAllFolders();
  }

  @override
  Future<void> saveFolder(FolderModel folder) async {
    await database.saveFolder(folder);
  }

  @override
  Future<void> deleteFolder(String name) async {
    await database.deleteFolder(name);
  }
}
