import 'dart:io';

abstract class FileService {
  /// Converts note content to plain text format
  static String formatNoteToPlainText({
    required String title,
    required String content,
    required String createdAt,
  }) {
    return 'TITLE: $title\nDATE: $createdAt\n\n$content';
  }

  /// Exports note as a .txt file
  Future<File?> exportToTxt({
    required String title,
    required String content,
    required String createdAt,
    required String targetPath,
  });

  /// Prepares note payload for PDF export
  Map<String, String> buildPdfPayload({
    required String title,
    required String content,
    required String createdAt,
  });
}
