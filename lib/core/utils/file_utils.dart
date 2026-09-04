abstract class AppFileUtils {
  /// Converts raw bytes count to human readable file size string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Extracts extension from file path
  static String getFileExtension(String path) {
    if (path.contains('.')) {
      return '.${path.split('.').last.toLowerCase()}';
    }
    return '';
  }

  /// Strips invalid filename characters for file exports
  static String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }
}
