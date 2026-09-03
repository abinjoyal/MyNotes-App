abstract class BackupService {
  /// Generates JSON backup string from notes list
  Future<String> generateBackupJson(List<Map<String, dynamic>> notes);

  /// Restores notes list from JSON backup string
  Future<List<Map<String, dynamic>>> parseBackupJson(String jsonString);

  /// Uploads backup payload to Google Drive
  Future<bool> syncToGoogleDrive(String backupJson);

  /// Downloads latest backup payload from Google Drive
  Future<String?> syncFromGoogleDrive();
}
