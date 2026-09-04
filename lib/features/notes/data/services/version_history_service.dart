import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/note_version.dart';

class VersionHistoryService {
  static final VersionHistoryService instance = VersionHistoryService._internal();
  factory VersionHistoryService() => instance;
  VersionHistoryService._internal() {
    _loadFromDisk();
  }

  final Map<String, List<NoteVersionSnapshot>> _historyMap = {};
  bool _isLoaded = false;
  late File _historyFile;

  Future<void> _loadFromDisk() async {
    if (_isLoaded) return;
    try {
      final dir = Directory.current;
      final dbDir = Directory('${dir.path}/database');
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      _historyFile = File('${dbDir.path}/mynotes_version_history.json');
      if (await _historyFile.exists()) {
        final content = await _historyFile.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            decoded.forEach((noteId, versions) {
              if (versions is List) {
                _historyMap[noteId] = versions
                    .map((map) => NoteVersionSnapshot.fromMap(Map<String, dynamic>.from(map)))
                    .toList();
              }
            });
          }
        }
      }
    } catch (_) {}
    _isLoaded = true;
  }

  Future<void> saveSnapshot({
    required String noteId,
    required String title,
    required String content,
    required Color indicatorColor,
    required List<String> tags,
  }) async {
    await _loadFromDisk();

    final effectiveTitle = title.trim().isEmpty ? 'Untitled Note' : title.trim();
    final words = content.trim().isEmpty ? 0 : content.trim().split(RegExp(r'\s+')).length;
    final chars = content.length;
    final now = DateTime.now();
    final timeStr = _formatTimestamp(now);

    final snapshot = NoteVersionSnapshot(
      id: '${now.millisecondsSinceEpoch}',
      noteId: noteId,
      title: effectiveTitle,
      content: content,
      indicatorColor: indicatorColor,
      tags: List.from(tags),
      timestamp: timeStr,
      wordCount: words,
      charCount: chars,
    );

    final list = _historyMap.putIfAbsent(noteId, () => []);

    // Don't add duplicate snapshot if content & title haven't changed from last snapshot
    if (list.isNotEmpty) {
      final last = list.first;
      if (last.title == effectiveTitle && last.content == content) {
        return;
      }
    }

    list.insert(0, snapshot);

    // Keep max 25 version snapshots per note
    if (list.length > 25) {
      list.removeLast();
    }

    await _flushToDisk();
  }

  List<NoteVersionSnapshot> getHistoryForNote(String noteId) {
    return List.unmodifiable(_historyMap[noteId] ?? []);
  }

  Future<void> clearHistoryForNote(String noteId) async {
    await _loadFromDisk();
    _historyMap.remove(noteId);
    await _flushToDisk();
  }

  Future<void> _flushToDisk() async {
    try {
      final dataMap = <String, dynamic>{};
      _historyMap.forEach((noteId, list) {
        dataMap[noteId] = list.map((s) => s.toMap()).toList();
      });
      final jsonStr = const JsonEncoder.withIndent('  ').convert(dataMap);
      await _historyFile.writeAsString(jsonStr);
    } catch (_) {}
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = monthNames[dt.month - 1];
    return '${dt.day} $month at $hour:$minute $ampm';
  }
}
