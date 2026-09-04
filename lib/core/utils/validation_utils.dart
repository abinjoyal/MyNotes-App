abstract class AppValidationUtils {
  /// Validates if input PIN string contains exactly 4 digits
  static bool isValidPin(String pin) {
    return RegExp(r'^\d{4}$').hasMatch(pin);
  }

  /// Validates folder name bounds
  static bool isValidFolderName(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty && trimmed.length <= 30;
  }

  /// Validates note title bounds
  static bool isValidNoteTitle(String title) {
    final trimmed = title.trim();
    return trimmed.isNotEmpty && trimmed.length <= 100;
  }

  /// Sanitizes search input string
  static String sanitizeQuery(String query) {
    return query.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
