abstract class AppStrings {
  // App Information
  static const String appName = 'Notes';

  // Navigation & Screen Headers
  static const String notes = appName;
  static const String trash = 'Trash';
  static const String settings = 'Settings';

  // Placeholders
  static const String searchPlaceholder = 'Search notes...';
  static const String titlePlaceholder = 'Title';
  static const String contentPlaceholder = 'Type something...';
  static const String categoryPlaceholder = 'Category name';

  // Action Buttons & Labels
  static const String createNote = 'Create Note';
  static const String editNote = 'Edit Note';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String share = 'Share';
  static const String copy = 'Copy';
  static const String duplicate = 'Duplicate';
  static const String undo = 'Undo';

  // Empty States
  static const String noNotesYet = 'No notes yet';
  static const String noNotesSubtitle =
      'Tap the + button to create your first note';
  static const String noMatchingNotes = 'No matching notes found';
  static const String trashEmpty = 'Trash is empty';

  // Dialog Prompts & Messages
  static const String deleteConfirmation =
      'Are you sure you want to delete this note?';
  static const String emptyTrashConfirmation =
      'Are you sure you want to permanently delete all items in trash?';
  static const String noteDeletedMessage = 'Note moved to trash';
  static const String noteRestoredMessage = 'Note restored';
  static const String noteSavedMessage = 'Note saved successfully';
}
