import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../datasources/folder_local_datasource.dart';
import '../models/folder_model.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource localDataSource;

  FolderRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Folder>> getFolders() async {
    final folderModels = await localDataSource.getAllFolders();
    // Return them as entities (Folder)
    return folderModels.cast<Folder>();
  }

  @override
  Future<List<Folder>> getTrashedFolders() async {
    final folderModels = await localDataSource.getTrashedFolders();
    return folderModels.cast<Folder>();
  }

  @override
  Future<void> saveFolder(Folder folder) async {
    final folderModel = FolderModel.fromEntity(folder);
    await localDataSource.saveFolder(folderModel);
  }

  @override
  Future<void> deleteFolderToTrash(String name) async {
    await localDataSource.deleteFolderToTrash(name);
  }

  @override
  Future<void> restoreFolderFromTrash(String name) async {
    await localDataSource.restoreFolderFromTrash(name);
  }

  @override
  Future<void> permanentlyDeleteFolderFromTrash(String name) async {
    await localDataSource.permanentlyDeleteFolderFromTrash(name);
  }
}
