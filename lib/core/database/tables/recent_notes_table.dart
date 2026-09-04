class RecentNotesTable {
  static const String tableName = 'recent_notes';

  static const String colId = 'id';
  static const String colNoteId = 'note_id';
  static const String colAccessedAt = 'accessed_at';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $colId TEXT PRIMARY KEY,
      $colNoteId TEXT NOT NULL,
      $colAccessedAt TEXT NOT NULL,
      FOREIGN KEY ($colNoteId) REFERENCES notes(id) ON DELETE CASCADE
    );
  ''';
}
