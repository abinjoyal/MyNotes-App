import '../entities/pinned_note.dart';

abstract class PinRepository {
  Future<List<PinnedNote>> getPinnedNotes();
  Future<void> pinNote(String noteId);
  Future<void> unpinNote(String noteId);
}
