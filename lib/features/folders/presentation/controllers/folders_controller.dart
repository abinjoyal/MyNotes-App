import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mynotes/features/folders/data/datasources/folder_local_datasource.dart';
import 'package:mynotes/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:mynotes/features/folders/domain/entities/folder.dart';
import 'package:mynotes/features/folders/domain/usecases/get_folders.dart';
import '../../../../core/database/database.dart';


final foldersProvider = ChangeNotifierProvider<FoldersController>((ref) {
  final dataSource = FolderLocalDataSourceImpl(database: AppDatabase.instance);
  final repository = FolderRepositoryImpl(localDataSource: dataSource);
  final getFoldersUseCase = GetFolders(repository);
  
  return FoldersController(
    getFoldersUseCase: getFoldersUseCase,
    repository: repository,
  );
});

class FoldersController extends ChangeNotifier {
  static FoldersController? _instance;
  static FoldersController get instance {
    if (_instance == null) {
      final dataSource = FolderLocalDataSourceImpl(database: AppDatabase.instance);
      final repository = FolderRepositoryImpl(localDataSource: dataSource);
      final getFoldersUseCase = GetFolders(repository);
      _instance = FoldersController(
        getFoldersUseCase: getFoldersUseCase,
        repository: repository,
      );
    }
    return _instance!;
  }

  final GetFolders getFoldersUseCase;
  final FolderRepositoryImpl repository;

  FoldersController({
    required this.getFoldersUseCase,
    required this.repository,
  }) {
    _instance = this;
    loadFolders();
  }

  final List<Folder> _folders = [];

  List<Folder> get folders => List.unmodifiable(_folders);

  Future<void> loadFolders() async {
    final fetchedFolders = await getFoldersUseCase();
    _folders.clear();
    _folders.addAll(fetchedFolders);
    notifyListeners();
  }

  void addFolder(String name, Color color) async {
    if (name.trim().isEmpty) return;
    
    final newFolder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      color: color,
    );
    
    _folders.add(newFolder);
    notifyListeners();

    await repository.saveFolder(newFolder);
  }
}
