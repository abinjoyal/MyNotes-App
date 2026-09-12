import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../features/notes/domain/entities/note.dart';

class NotesTable {
  static const String tableName = 'notes';

  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colContent = 'content';
  static const String colColorValue = 'color_value';
  static const String colTags = 'tags';
  static const String colUpdatedAt = 'updated_at';
  static const String colIsPinned = 'is_pinned';
  static const String colFolderName = 'folder_name';
  static const String colIsTrashed = 'is_trashed';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $colId TEXT PRIMARY KEY,
      $colTitle TEXT NOT NULL,
      $colContent TEXT NOT NULL,
      $colColorValue INTEGER NOT NULL,
      $colTags TEXT,
      $colUpdatedAt TEXT NOT NULL,
      $colIsPinned INTEGER NOT NULL DEFAULT 0,
      $colFolderName TEXT,
      $colIsTrashed INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static Map<String, dynamic> toMap(Note note) {
    return {
      colId: note.id,
      colTitle: note.title,
      colContent: note.content,
      colColorValue: note.indicatorColor.value,
      colTags: jsonEncode(note.tags),
      colUpdatedAt: note.updatedAt,
      colIsPinned: note.isPinned ? 1 : 0,
      colFolderName: note.folderName,
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map[colTags] != null) {
      try {
        final decoded = jsonDecode(map[colTags].toString());
        if (decoded is List) {
          parsedTags = List<String>.from(decoded);
        }
      } catch (_) {}
    }

    return Note(
      id: map[colId]?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map[colTitle]?.toString() ?? 'Untitled Note',
      content: map[colContent]?.toString() ?? '',
      indicatorColor: Color(map[colColorValue] is int ? map[colColorValue] : 0xFF635BFF),
      tags: parsedTags,
      updatedAt: map[colUpdatedAt]?.toString() ?? 'Just now',
      isPinned: map[colIsPinned] == 1 || map[colIsPinned] == true,
      folderName: map[colFolderName]?.toString(),
    );
  }
}
