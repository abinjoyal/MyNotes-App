import 'dart:convert';
import 'dart:io';
import '../../features/notes/domain/entities/note.dart';
import '../../features/notes/presentation/controllers/notes_controller.dart';
import 'tables/notes_table.dart';
import 'tables/folders_table.dart';
import 'tables/attachments_table.dart';
import 'tables/recent_notes_table.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  factory AppDatabase() => instance;
  AppDatabase._internal();

  bool _isInitialized = false;
  late File _dbFile;

  List<Note> _notesDb = [];
  List<Note> _trashedNotesDb = [];
  List<FolderItemModel> _foldersDb = [];

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final dir = Directory.current;
      final dbDir = Directory('${dir.path}/database');
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      _dbFile = File('${dbDir.path}/mynotes_local_db.json');
      if (await _dbFile.exists()) {
        final content = await _dbFile.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            if (decoded['notes'] is List) {
              _notesDb = (decoded['notes'] as List)
                  .map((map) => NotesTable.fromMap(Map<String, dynamic>.from(map)))
                  .toList();
            }
            if (decoded['trashedNotes'] is List) {
              _trashedNotesDb = (decoded['trashedNotes'] as List)
                  .map((map) => NotesTable.fromMap(Map<String, dynamic>.from(map)))
                  .toList();
            }
            if (decoded['folders'] is List) {
              _foldersDb = (decoded['folders'] as List)
                  .map((map) => FoldersTable.fromMap(Map<String, dynamic>.from(map)))
                  .toList();
            }
          }
        }
      } else {
        await _flushToDisk();
      }
    } catch (_) {}

    _isInitialized = true;
  }

  Future<List<Note>> getAllNotes() async {
    await init();
    return List.unmodifiable(_notesDb);
  }

  Future<List<Note>> getTrashedNotes() async {
    await init();
    return List.unmodifiable(_trashedNotesDb);
  }

  Future<List<FolderItemModel>> getAllFolders() async {
    await init();
    return List.unmodifiable(_foldersDb);
  }

  Future<void> saveNote(Note note) async {
    await init();
    final index = _notesDb.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notesDb[index] = note;
    } else {
      _notesDb.insert(0, note);
    }
    await _flushToDisk();
  }

  Future<void> deleteNoteToTrash(String id) async {
    await init();
    final index = _notesDb.indexWhere((n) => n.id == id);
    if (index != -1) {
      final deleted = _notesDb.removeAt(index);
      _trashedNotesDb.insert(0, deleted);
      await _flushToDisk();
    }
  }

  Future<void> saveFolder(FolderItemModel folder) async {
    await init();
    final index = _foldersDb.indexWhere((f) => f.name == folder.name);
    if (index != -1) {
      _foldersDb[index] = folder;
    } else {
      _foldersDb.add(folder);
    }
    await _flushToDisk();
  }

  Future<void> _flushToDisk() async {
    try {
      final dataMap = {
        'version': 1,
        'schemas': [
          NotesTable.tableName,
          FoldersTable.tableName,
          AttachmentsTable.tableName,
          RecentNotesTable.tableName,
        ],
        'notes': _notesDb.map((n) => NotesTable.toMap(n)).toList(),
        'trashedNotes': _trashedNotesDb.map((n) => NotesTable.toMap(n)).toList(),
        'folders': _foldersDb.map((f) => FoldersTable.toMap(f)).toList(),
      };
      final jsonStr = const JsonEncoder.withIndent('  ').convert(dataMap);
      await _dbFile.writeAsString(jsonStr);
    } catch (_) {}
  }
}
