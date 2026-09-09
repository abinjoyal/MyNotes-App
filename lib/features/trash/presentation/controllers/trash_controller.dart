import 'package:flutter/material.dart';
import '../../domain/entities/trash_item.dart';
import '../../domain/usecases/get_trash_items.dart';
import '../../domain/usecases/restore_note.dart';
import '../../domain/usecases/delete_permanently.dart';
import '../../domain/usecases/empty_trash.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';

class TrashController extends ChangeNotifier {
  final GetTrashItemsUseCase getTrashItemsUseCase;
  final RestoreNoteUseCase restoreNoteUseCase;
  final DeleteNotePermanentlyUseCase deleteNotePermanentlyUseCase;
  final EmptyTrashUseCase emptyTrashUseCase;

  List<TrashItem> _items = [];
  bool _isLoading = false;
  String? _error;

  TrashController({
    required this.getTrashItemsUseCase,
    required this.restoreNoteUseCase,
    required this.deleteNotePermanentlyUseCase,
    required this.emptyTrashUseCase,
  }) {
    loadTrash();
  }

  List<TrashItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTrash() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await getTrashItemsUseCase();
    } catch (e) {
      _error = 'Failed to load trash: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreNote(String id) async {
    try {
      await restoreNoteUseCase(id);
      _items.removeWhere((item) => item.note.id == id);
      await NotesController.instance.loadFromDatabase(); // Sync main app
      notifyListeners();
    } catch (e) {
      _error = 'Failed to restore note: $e';
      notifyListeners();
    }
  }

  Future<void> deletePermanently(String id) async {
    try {
      await deleteNotePermanentlyUseCase(id);
      _items.removeWhere((item) => item.note.id == id);
      await NotesController.instance.loadFromDatabase(); // Sync main app
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete note: $e';
      notifyListeners();
    }
  }

  Future<void> emptyTrash() async {
    try {
      await emptyTrashUseCase();
      _items.clear();
      await NotesController.instance.loadFromDatabase(); // Sync main app
      notifyListeners();
    } catch (e) {
      _error = 'Failed to empty trash: $e';
      notifyListeners();
    }
  }
}
