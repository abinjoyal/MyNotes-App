class AttachmentsTable {
  static const String tableName = 'attachments';

  static const String colId = 'id';
  static const String colNoteId = 'note_id';
  static const String colFilePath = 'file_path';
  static const String colFileType = 'file_type';
  static const String colCreatedAt = 'created_at';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $colId TEXT PRIMARY KEY,
      $colNoteId TEXT NOT NULL,
      $colFilePath TEXT NOT NULL,
      $colFileType TEXT NOT NULL,
      $colCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($colNoteId) REFERENCES notes(id) ON DELETE CASCADE
    );
  ''';
}
