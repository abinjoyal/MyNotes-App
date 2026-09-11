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
  final List<Folder> _trashedFolders = [];

  List<Folder> get folders => List.unmodifiable(_folders);
  List<Folder> get trashedFolders => List.unmodifiable(_trashedFolders);

  Future<void> loadFolders() async {
    final fetchedFolders = await getFoldersUseCase();
    final fetchedTrashed = await repository.getTrashedFolders();
    _folders.clear();
    _folders.addAll(fetchedFolders);
    _trashedFolders.clear();
    _trashedFolders.addAll(fetchedTrashed);
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

  void deleteFolderToTrash(String name) async {
    final index = _folders.indexWhere((f) => f.name == name);
    if (index != -1) {
      final deleted = _folders.removeAt(index);
      _trashedFolders.insert(0, deleted);
      notifyListeners();
      await repository.deleteFolderToTrash(name);
    }
  }

  void restoreFolderFromTrash(String name) async {
    final index = _trashedFolders.indexWhere((f) => f.name == name);
    if (index != -1) {
      final restored = _trashedFolders.removeAt(index);
      _folders.add(restored);
      notifyListeners();
      await repository.restoreFolderFromTrash(name);
    }
  }

  void permanentlyDeleteFolderFromTrash(String name) async {
    _trashedFolders.removeWhere((f) => f.name == name);
    notifyListeners();
    await repository.permanentlyDeleteFolderFromTrash(name);
  }

  void emptyTrash() {
    _trashedFolders.clear();
    notifyListeners();
  }
}
