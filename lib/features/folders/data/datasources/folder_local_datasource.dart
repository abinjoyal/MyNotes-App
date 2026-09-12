import '../../../../core/database/database.dart';
import '../models/folder_model.dart';

abstract class FolderLocalDataSource {
  Future<List<FolderModel>> getAllFolders();
  Future<List<FolderModel>> getTrashedFolders();
  Future<void> saveFolder(FolderModel folder);
  Future<void> toggleFolderLock(String name, bool isLocked);
  Future<void> deleteFolderToTrash(String name);
  Future<void> restoreFolderFromTrash(String name);
  Future<void> permanentlyDeleteFolderFromTrash(String name);
}

class FolderLocalDataSourceImpl implements FolderLocalDataSource {
  final AppDatabase database;

  FolderLocalDataSourceImpl({required this.database});

  @override
  Future<List<FolderModel>> getAllFolders() async {
    return await database.getAllFolders();
  }

  @override
  Future<List<FolderModel>> getTrashedFolders() async {
    return await database.getTrashedFolders();
  }

  @override
  Future<void> saveFolder(FolderModel folder) async {
    await database.saveFolder(folder);
  }

  @override
  Future<void> deleteFolderToTrash(String name) async {
    await database.deleteFolderToTrash(name);
  }

  Future<void> restoreFolderFromTrash(String name) async {
    await database.restoreFolderFromTrash(name);
  }

  @override
  Future<void> toggleFolderLock(String name, bool isLocked) async {
    await database.toggleFolderLock(name, isLocked);
  }

  @override
  Future<void> permanentlyDeleteFolderFromTrash(String name) async {
    await database.permanentlyDeleteFolderFromTrash(name);
  }
}
