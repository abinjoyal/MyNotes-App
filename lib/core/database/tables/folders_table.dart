import 'package:flutter/material.dart';
import '../../../features/notes/presentation/controllers/notes_controller.dart';

class FoldersTable {
  static const String tableName = 'folders';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colColorValue = 'color_value';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $colId TEXT PRIMARY KEY,
      $colName TEXT NOT NULL UNIQUE,
      $colColorValue INTEGER NOT NULL
    );
  ''';

  static Map<String, dynamic> toMap(FolderItemModel folder) {
    return {
      colId: folder.id,
      colName: folder.name,
      colColorValue: folder.color.value,
    };
  }

  static FolderItemModel fromMap(Map<String, dynamic> map) {
    return FolderItemModel(
      id: map[colId]?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map[colName]?.toString() ?? 'Folder',
      color: Color(map[colColorValue] is int ? map[colColorValue] : 0xFF635BFF),
    );
  }
}
