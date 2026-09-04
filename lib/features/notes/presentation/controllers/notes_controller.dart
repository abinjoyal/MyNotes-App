import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import '../../../../core/database/database.dart';

class FolderItemModel {
  final String id;
  final String name;
  final Color color;

  const FolderItemModel({
    required this.id,
    required this.name,
    required this.color,
  });
}

class NotesController extends ChangeNotifier {
  static final NotesController instance = NotesController._internal();

  factory NotesController() {
    return instance;
  }

  NotesController._internal() {
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final dbNotes = await AppDatabase.instance.getAllNotes();
    final dbTrashed = await AppDatabase.instance.getTrashedNotes();
    final dbFolders = await AppDatabase.instance.getAllFolders();

    _notes.clear();
    _notes.addAll(dbNotes);

    _trashedNotes.clear();
    _trashedNotes.addAll(dbTrashed);

    _folders.clear();
    _folders.addAll(dbFolders);

    notifyListeners();
  }

  final List<Note> _notes = [];
  final List<Note> _trashedNotes = [];
  final List<FolderItemModel> _folders = [];

  List<Note> get notes => List.unmodifiable(_notes);
  List<Note> get trashedNotes => List.unmodifiable(_trashedNotes);
  List<FolderItemModel> get folders => List.unmodifiable(_folders);

  List<Note> get pinnedNotes =>
      _notes.where((note) => note.isPinned).toList();

  int get totalNotesCount => _notes.length;
  int get pinnedNotesCount => pinnedNotes.length;
  int get trashedNotesCount => _trashedNotes.length;

  void addFolder(String name, Color color) {
    if (name.trim().isEmpty) return;
    final folder = FolderItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      color: color,
    );
    _folders.add(folder);
    AppDatabase.instance.saveFolder(folder);
    notifyListeners();
  }

  List<String> get allTags {
    final set = <String>{};
    for (final note in _notes) {
      set.addAll(note.tags);
    }
    return set.toList();
  }

  Note createTemplateNote(String type) {
    switch (type) {
      case 'checklist':
        return Note(
          id: '',
          title: 'Project Task Checklist',
          content: '- [ ] Complete design mockups\n- [ ] Write integration unit tests\n- [ ] Review PR and launch to production',
          indicatorColor: const Color(0xFF00C853),
          tags: ['#task', '#project'],
          updatedAt: 'Draft',
        );
      case 'journal':
        return Note(
          id: '',
          title: 'Daily Journal - ${DateTime.now().day}/${DateTime.now().month}',
          content: '### Today\'s Focus\n1. Primary goal\n2. Secondary task\n\n### Reflection & Notes\n- What went well today?',
          indicatorColor: const Color(0xFFFFB020),
          tags: ['#daily', '#reflection'],
          updatedAt: 'Draft',
        );
      case 'meeting':
        return Note(
          id: '',
          title: 'Meeting Notes',
          content: '### Attendees\n- \n\n### Agenda\n- Discussion points\n\n### Action Items\n- [ ] Next steps',
          indicatorColor: const Color(0xFF4C6FFF),
          tags: ['#meeting'],
          updatedAt: 'Draft',
        );
      default:
        return Note(
          id: '',
          title: '',
          content: '',
          indicatorColor: const Color(0xFF635BFF),
          tags: ['#new'],
          updatedAt: 'Draft',
        );
    }
  }

  List<Note> getNotesByFolder(String folderName) {
    return _notes.where((note) => note.folderName == folderName).toList();
  }

  int getFolderNotesCount(String folderName) {
    return getNotesByFolder(folderName).length;
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  void saveNote({
    String? id,
    required String title,
    required String content,
    required Color indicatorColor,
    required List<String> tags,
    bool isPinned = false,
    String? folderName,
  }) {
    final nowStr = _formatTimestamp(DateTime.now());
    final effectiveTitle = title.trim().isEmpty ? 'Untitled Note' : title.trim();

    if (id != null && id.isNotEmpty) {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index != -1) {
        final updatedNote = _notes[index].copyWith(
          title: effectiveTitle,
          content: content,
          indicatorColor: indicatorColor,
          tags: tags,
          updatedAt: nowStr,
          isPinned: isPinned,
          folderName: folderName ?? _notes[index].folderName,
        );
        _notes[index] = updatedNote;
        AppDatabase.instance.saveNote(updatedNote);
        notifyListeners();
        return;
      }
    }

    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: effectiveTitle,
      content: content,
      indicatorColor: indicatorColor,
      tags: tags,
      updatedAt: nowStr,
      isPinned: isPinned,
      folderName: folderName,
    );

    _notes.insert(0, newNote);
    AppDatabase.instance.saveNote(newNote);
    notifyListeners();
  }

  void deleteNote(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final deletedNote = _notes.removeAt(index);
      _trashedNotes.insert(0, deletedNote);
      AppDatabase.instance.deleteNoteToTrash(id);
      notifyListeners();
    }
  }

  void restoreFromTrash(String id) {
    final index = _trashedNotes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final restoredNote = _trashedNotes.removeAt(index);
      _notes.insert(0, restoredNote);
      notifyListeners();
    }
  }

  void permanentlyDeleteFromTrash(String id) {
    _trashedNotes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  void emptyTrash() {
    _trashedNotes.clear();
    notifyListeners();
  }

  void togglePin(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isPinned: !_notes[index].isPinned,
      );
      notifyListeners();
    }
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return 'Just now at $hour:$minute $ampm';
  }
}
