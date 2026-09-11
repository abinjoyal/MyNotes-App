import '../entities/folder.dart';

abstract class FolderRepository {
  Future<List<Folder>> getFolders();
  Future<List<Folder>> getTrashedFolders();
  Future<void> saveFolder(Folder folder);
  Future<void> deleteFolderToTrash(String name);
  Future<void> restoreFolderFromTrash(String name);
  Future<void> permanentlyDeleteFolderFromTrash(String name);
}
