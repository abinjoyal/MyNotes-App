import '../entities/folder.dart';

abstract class FolderRepository {
  Future<List<Folder>> getFolders();
  Future<void> saveFolder(Folder folder);
}
