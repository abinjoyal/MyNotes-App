import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

class BackupResult {
  final String jsonContent;
  final String timestamp;
  final String formattedSize;
  final int totalNotes;

  const BackupResult({
    required this.jsonContent,
    required this.timestamp,
    required this.formattedSize,
    required this.totalNotes,
  });
}

class BackupService {
  static final BackupService instance = BackupService._internal();
  factory BackupService() => instance;
  BackupService._internal();

  /// Generates structured JSON string payload for all notes & settings
  BackupResult createBackupPayload() {
    final notesController = NotesController.instance;
    final settingsController = SettingsController.instance;

    final now = DateTime.now();
    final timestampStr = _formatDate(now);

    final notesData = notesController.notes.map((note) => _noteToMap(note)).toList();
    final trashedNotesData = notesController.trashedNotes.map((note) => _noteToMap(note)).toList();
    final foldersData = notesController.folders.map((folder) => {
      'id': folder.id,
      'name': folder.name,
      'colorValue': folder.color.value,
    }).toList();

    final backupMap = {
      'app': 'MyNotes',
      'version': '1.0.0',
      'createdAt': now.toIso8601String(),
      'formattedTimestamp': timestampStr,
      'metadata': {
        'totalNotes': notesController.totalNotesCount,
        'totalTrashed': notesController.trashedNotesCount,
        'totalFolders': notesController.folders.length,
      },
      'settings': {
        'theme': settingsController.selectedTheme,
        'layout': settingsController.selectedLayout,
        'fontSize': settingsController.fontSize,
        'enablePinLock': settingsController.enablePinLock,
        'enableBiometrics': settingsController.enableBiometrics,
      },
      'folders': foldersData,
      'notes': notesData,
      'trashedNotes': trashedNotesData,
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(backupMap);
    final sizeInBytes = utf8.encode(jsonStr).length;
    final formattedSizeStr = _formatSize(sizeInBytes);

    return BackupResult(
      jsonContent: jsonStr,
      timestamp: timestampStr,
      formattedSize: formattedSizeStr,
      totalNotes: notesController.totalNotesCount,
    );
  }

  /// Exports backup JSON directly to local storage file
  Future<String?> exportBackupToFile() async {
    try {
      final res = createBackupPayload();
      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = 'mynotes_backup_${dateStr}_$timeStr.json';

      final dir = Directory.current;
      final backupDir = Directory('${dir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final file = File('${backupDir.path}/$fileName');
      await file.writeAsString(res.jsonContent);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Restores notes, folders & settings from a valid JSON backup string
  bool restoreFromBackupPayload(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic> || decoded['app'] != 'MyNotes') {
        return false;
      }

      final notesController = NotesController.instance;

      // Restore Folders
      if (decoded['folders'] is List) {
        for (final folderItem in decoded['folders']) {
          final name = folderItem['name'] ?? '';
          final colorVal = folderItem['colorValue'] ?? 0xFF635BFF;
          if (name.toString().isNotEmpty) {
            notesController.addFolder(name.toString(), Color(colorVal as int));
          }
        }
      }

      // Restore Notes
      if (decoded['notes'] is List) {
        for (final noteMap in decoded['notes']) {
          final note = _mapToNote(noteMap);
          notesController.saveNote(
            id: note.id,
            title: note.title,
            content: note.content,
            indicatorColor: note.indicatorColor,
            tags: note.tags,
            isPinned: note.isPinned,
            folderName: note.folderName,
          );
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _noteToMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'colorValue': note.indicatorColor.value,
      'tags': note.tags,
      'updatedAt': note.updatedAt,
      'isPinned': note.isPinned,
      'folderName': note.folderName,
    };
  }

  Note _mapToNote(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] ?? 'Untitled Note',
      content: map['content'] ?? '',
      indicatorColor: Color(map['colorValue'] ?? 0xFF635BFF),
      tags: List<String>.from(map['tags'] ?? []),
      updatedAt: map['updatedAt'] ?? 'Restored',
      isPinned: map['isPinned'] ?? false,
      folderName: map['folderName'],
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    final day = dt.day;
    final year = dt.year;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year at $hour:$minute $ampm';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
