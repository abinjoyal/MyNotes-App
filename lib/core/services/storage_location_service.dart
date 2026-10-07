import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/notes/domain/entities/note.dart';
import '../../features/settings/controllers/settings_controller.dart';
import 'storage_service.dart';

enum StorageMigrationOption { move, copy, switchOnly }

class StorageLocationService {
  static final StorageLocationService instance =
      StorageLocationService._internal();
  factory StorageLocationService() => instance;
  StorageLocationService._internal();

  static const String keySetupCompleted = 'storage_setup_completed';
  static const String keyStoragePath = 'root_storage_path';

  bool get isSetupCompleted {
    return StorageService.instance.getBool(
      keySetupCompleted,
      defaultValue: false,
    );
  }

  Future<String> getDefaultStoragePath() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      return '${docDir.path}${Platform.pathSeparator}MyNotes';
    } catch (_) {
      final currentDir = Directory.current;
      return '${currentDir.path}${Platform.pathSeparator}MyNotes';
    }
  }

  Future<String> getStoragePath() async {
    final savedPath = StorageService.instance.getString(keyStoragePath);
    if (savedPath.isNotEmpty) {
      return savedPath;
    }
    final defaultPath = await getDefaultStoragePath();
    await StorageService.instance.saveString(keyStoragePath, defaultPath);
    return defaultPath;
  }

  String ensureMyNotesSubfolder(String rawPath) {
    if (rawPath.isEmpty) return rawPath;
    final trimmed = rawPath.trim();
    final normalized = trimmed
        .replaceAll('/', Platform.pathSeparator)
        .replaceAll('\\', Platform.pathSeparator);
    final segments = normalized
        .split(Platform.pathSeparator)
        .where((s) => s.isNotEmpty)
        .toList();
    if (segments.isNotEmpty) {
      final lastSegment = segments.last.toLowerCase();
      if (lastSegment == 'mynotes' || lastSegment == 'my notes') {
        return normalized;
      }
    }
    return '$normalized${Platform.pathSeparator}MyNotes';
  }

  Future<void> completeSetup(String targetPath) async {
    final finalPath = ensureMyNotesSubfolder(targetPath);
    await initializeDirectoryStructure(finalPath);
    await StorageService.instance.saveString(keyStoragePath, finalPath);
    await StorageService.instance.saveBool(keySetupCompleted, true);
  }

  Future<void> initializeDirectoryStructure(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) {
      await rootDir.create(recursive: true);
    }

    final notesDir = Directory('$rootPath${Platform.pathSeparator}Notes');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }

    final tasksDir = Directory('$rootPath${Platform.pathSeparator}Tasks');
    if (!await tasksDir.exists()) {
      await tasksDir.create(recursive: true);
    }

    final foldersDir = Directory('$rootPath${Platform.pathSeparator}Folders');
    if (!await foldersDir.exists()) {
      await foldersDir.create(recursive: true);
    }
  }

  Future<String> getFormattedStorageUsage([String? rootPath]) async {
    final path = rootPath ?? await getStoragePath();
    final dir = Directory(path);
    if (!await dir.exists()) return '0.0 MB';

    int totalBytes = 0;
    try {
      await for (final file in dir.list(recursive: true, followLinks: false)) {
        if (file is File) {
          totalBytes += await file.length();
        }
      }
    } catch (_) {}

    return _formatBytes(totalBytes);
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0.0 MB';
    if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    }
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    if (double.parse(mb) >= 1024) {
      final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(2);
      return '$gb GB';
    }
    return '$mb MB';
  }

  Future<void> changeStoragePath({
    required String oldPath,
    required String newPath,
    required StorageMigrationOption option,
  }) async {
    final finalNewPath = ensureMyNotesSubfolder(newPath);
    await initializeDirectoryStructure(finalNewPath);

    if (option == StorageMigrationOption.move ||
        option == StorageMigrationOption.copy) {
      final oldDir = Directory(oldPath);
      if (await oldDir.exists()) {
        await _copyDirectory(oldDir, Directory(finalNewPath));
        if (option == StorageMigrationOption.move && oldPath != finalNewPath) {
          try {
            await oldDir.delete(recursive: true);
          } catch (_) {}
        }
      }
    }

    await StorageService.instance.saveString(keyStoragePath, finalNewPath);
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    await for (final entity in source.list(recursive: false)) {
      final newPath =
          '${destination.path}${Platform.pathSeparator}${_basename(entity.path)}';
      if (entity is Directory) {
        final newDir = Directory(newPath);
        await _copyDirectory(entity, newDir);
      } else if (entity is File) {
        await entity.copy(newPath);
      }
    }
  }

  String _basename(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  String sanitizeFilename(String name) {
    final sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return sanitized.isEmpty ? 'Untitled' : sanitized;
  }

  Future<void> saveNoteToFile(Note note) async {
    try {
      final rootPath = await getStoragePath();
      await initializeDirectoryStructure(rootPath);

      String targetDirPath;
      if (note.folderName != null && note.folderName!.trim().isNotEmpty) {
        final folderNameSanitized = sanitizeFilename(note.folderName!);
        targetDirPath =
            '$rootPath${Platform.pathSeparator}Folders${Platform.pathSeparator}$folderNameSanitized';
      } else if (_isTaskChecklist(note)) {
        targetDirPath = '$rootPath${Platform.pathSeparator}Tasks';
      } else {
        targetDirPath = '$rootPath${Platform.pathSeparator}Notes';
      }

      final dir = Directory(targetDirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final filename = sanitizeFilename(
        note.title.isEmpty ? 'Untitled Note' : note.title,
      );
      final ext = SettingsController.instance.fileExtension;
      final filePath = '$targetDirPath${Platform.pathSeparator}$filename$ext';

      final file = File(filePath);
      final tagsStr = note.tags.isNotEmpty ? note.tags.join(', ') : 'None';

      String fileContent;
      if (ext == '.json') {
        fileContent = const JsonEncoder.withIndent('  ').convert(note.toMap());
      } else if (ext == '.txt') {
        fileContent = '''${note.title.isEmpty ? 'Untitled Note' : note.title}
Updated: ${note.updatedAt}
Tags: $tagsStr

${note.content}
''';
      } else {
        fileContent = '''# ${note.title.isEmpty ? 'Untitled Note' : note.title}

Updated: ${note.updatedAt}
Tags: $tagsStr

${note.content}
''';
      }

      await file.writeAsString(fileContent);
    } catch (_) {}
  }

  Future<void> deleteNoteFile(Note note) async {
    try {
      final rootPath = await getStoragePath();
      final filename = sanitizeFilename(
        note.title.isEmpty ? 'Untitled Note' : note.title,
      );

      final extensions = ['.md', '.txt', '.json'];
      for (final ext in extensions) {
        final pathsToTry = [
          '$rootPath${Platform.pathSeparator}Notes${Platform.pathSeparator}$filename$ext',
          '$rootPath${Platform.pathSeparator}Tasks${Platform.pathSeparator}$filename$ext',
        ];

        if (note.folderName != null && note.folderName!.trim().isNotEmpty) {
          final folderNameSanitized = sanitizeFilename(note.folderName!);
          pathsToTry.add(
            '$rootPath${Platform.pathSeparator}Folders${Platform.pathSeparator}$folderNameSanitized${Platform.pathSeparator}$filename$ext',
          );
        }

        for (final p in pathsToTry) {
          final f = File(p);
          if (await f.exists()) {
            await f.delete();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> syncAllNotesToFiles(List<Note> notes) async {
    for (final note in notes) {
      await saveNoteToFile(note);
    }
  }

  bool _isTaskChecklist(Note note) {
    final content = note.content.trim();
    return note.tags.contains('#task') ||
        note.tags.contains('#checklist') ||
        note.tags.contains('task') ||
        note.tags.contains('checklist') ||
        content.startsWith('- [ ]') ||
        content.startsWith('- [x]') ||
        content.startsWith('- [X]');
  }

  Future<File?> createZipBackup() async {
    try {
      final rootPath = await getStoragePath();
      final sourceDir = Directory(rootPath);
      if (!await sourceDir.exists()) return null;

      final tempDir = await getTemporaryDirectory();
      final zipPath =
          '${tempDir.path}${Platform.pathSeparator}MyNotes_Backup.zip';

      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      await encoder.addDirectory(sourceDir, includeDirName: true);
      encoder.close();

      return File(zipPath);
    } catch (_) {
      return null;
    }
  }
}
