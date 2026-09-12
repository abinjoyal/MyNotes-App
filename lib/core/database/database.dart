import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../../features/notes/domain/entities/note.dart';
import '../../features/folders/data/models/folder_model.dart';
import 'tables/notes_table.dart';
import 'tables/folders_table.dart';
import 'tables/attachments_table.dart';
import 'tables/recent_notes_table.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  factory AppDatabase() => instance;
  AppDatabase._internal();

  Database? _database;

  Future<void> init() async {
    await database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mynotes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
    
    // Migration for is_locked column
    try {
      await db.execute('ALTER TABLE folders ADD COLUMN is_locked INTEGER NOT NULL DEFAULT 0');
    } catch (e) {
      // Column might already exist, ignore error
    }
    
    return db;
  }

  Future _createDB(Database db, int version) async {
    await db.execute(NotesTable.createTableSql);
    await db.execute(FoldersTable.createTableSql);
    await db.execute(AttachmentsTable.createTableSql);
    await db.execute(RecentNotesTable.createTableSql);
  }

  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query(
      NotesTable.tableName,
      where: '${NotesTable.colIsTrashed} = ?',
      whereArgs: [0],
      orderBy: '${NotesTable.colUpdatedAt} DESC',
    );
    return result.map((json) => NotesTable.fromMap(json)).toList();
  }

  Future<List<Note>> getTrashedNotes() async {
    final db = await instance.database;
    final result = await db.query(
      NotesTable.tableName,
      where: '${NotesTable.colIsTrashed} = ?',
      whereArgs: [1],
      orderBy: '${NotesTable.colUpdatedAt} DESC',
    );
    return result.map((json) => NotesTable.fromMap(json)).toList();
  }

  Future<List<FolderModel>> getAllFolders() async {
    final db = await instance.database;
    final result = await db.query(
      FoldersTable.tableName,
      where: '${FoldersTable.colIsTrashed} = ?',
      whereArgs: [0],
    );
    return result.map((json) => FoldersTable.fromMap(json)).toList();
  }

  Future<List<FolderModel>> getTrashedFolders() async {
    final db = await instance.database;
    final result = await db.query(
      FoldersTable.tableName,
      where: '${FoldersTable.colIsTrashed} = ?',
      whereArgs: [1],
    );
    return result.map((json) => FoldersTable.fromMap(json)).toList();
  }

  Future<void> saveNote(Note note) async {
    final db = await instance.database;
    final map = NotesTable.toMap(note);
    map[NotesTable.colIsTrashed] = 0;
    
    await db.insert(
      NotesTable.tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNoteToTrash(String id) async {
    final db = await instance.database;
    await db.update(
      NotesTable.tableName,
      {NotesTable.colIsTrashed: 1},
      where: '${NotesTable.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreFromTrash(String id) async {
    final db = await instance.database;
    await db.update(
      NotesTable.tableName,
      {NotesTable.colIsTrashed: 0},
      where: '${NotesTable.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> permanentlyDeleteFromTrash(String id) async {
    final db = await instance.database;
    await db.delete(
      NotesTable.tableName,
      where: '${NotesTable.colId} = ? AND ${NotesTable.colIsTrashed} = ?',
      whereArgs: [id, 1],
    );
  }

  Future<void> emptyTrash() async {
    final db = await instance.database;
    await db.delete(
      NotesTable.tableName,
      where: '${NotesTable.colIsTrashed} = ?',
      whereArgs: [1],
    );
    await db.delete(
      FoldersTable.tableName,
      where: '${FoldersTable.colIsTrashed} = ?',
      whereArgs: [1],
    );
  }

  Future<void> saveFolder(FolderModel folder) async {
    final db = await instance.database;
    final map = FoldersTable.toMap(folder);
    map[FoldersTable.colIsTrashed] = 0;
    
    await db.insert(
      FoldersTable.tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFolderToTrash(String name) async {
    final db = await instance.database;
    await db.update(
      FoldersTable.tableName,
      {FoldersTable.colIsTrashed: 1},
      where: '${FoldersTable.colName} = ?',
      whereArgs: [name],
    );
  }

  Future<void> restoreFolderFromTrash(String name) async {
    final db = await instance.database;
    await db.update(
      FoldersTable.tableName,
      {FoldersTable.colIsTrashed: 0},
      where: '${FoldersTable.colName} = ?',
      whereArgs: [name],
    );
  }

  Future<void> toggleFolderLock(String name, bool isLocked) async {
    final db = await instance.database;
    await db.update(
      FoldersTable.tableName,
      {FoldersTable.colIsLocked: isLocked ? 1 : 0},
      where: '${FoldersTable.colName} = ?',
      whereArgs: [name],
    );
  }

  Future<void> permanentlyDeleteFolderFromTrash(String name) async {
    final db = await instance.database;
    
    // Set notes in this folder to have null folderName
    await db.update(
      NotesTable.tableName,
      {NotesTable.colFolderName: null},
      where: '${NotesTable.colFolderName} = ?',
      whereArgs: [name],
    );

    // Delete the folder
    await db.delete(
      FoldersTable.tableName,
      where: '${FoldersTable.colName} = ? AND ${FoldersTable.colIsTrashed} = ?',
      whereArgs: [name, 1],
    );
  }
}
