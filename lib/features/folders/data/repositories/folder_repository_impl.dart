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
  Future<void> saveFolder(Folder folder) async {
    final folderModel = FolderModel.fromEntity(folder);
    await localDataSource.saveFolder(folderModel);
  }
}
