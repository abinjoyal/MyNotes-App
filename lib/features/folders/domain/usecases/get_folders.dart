import '../entities/folder.dart';
import '../repositories/folder_repository.dart';

class GetFolders {
  final FolderRepository repository;

  GetFolders(this.repository);

  Future<List<Folder>> call() async {
    return await repository.getFolders();
  }
}
