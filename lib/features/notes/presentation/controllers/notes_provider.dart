import 'package:flutter_riverpod/legacy.dart';
import 'notes_controller.dart';

/// Provider for the NotesController.
/// Using ChangeNotifierProvider allows for a smooth migration
/// from the singleton pattern to Riverpod while preserving the existing API.
final notesProvider = ChangeNotifierProvider<NotesController>((ref) {
  return NotesController();
});
