import '../models/pinned_note_model.dart';

abstract class PinLocalDataSource {
  Future<List<PinnedNoteModel>> getPinnedNotes();
  Future<void> pinNote(String noteId);
  Future<void> unpinNote(String noteId);
}

class PinLocalDataSourceImpl implements PinLocalDataSource {
  // Simulating local storage for pinned notes
  final List<PinnedNoteModel> _pinnedNotes = [];

  @override
  Future<List<PinnedNoteModel>> getPinnedNotes() async {
    return _pinnedNotes;
  }

  @override
  Future<void> pinNote(String noteId) async {
    final newPinned = PinnedNoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      noteId: noteId,
      pinnedAt: DateTime.now(),
    );
    _pinnedNotes.add(newPinned);
  }

  @override
  Future<void> unpinNote(String noteId) async {
    _pinnedNotes.removeWhere((note) => note.noteId == noteId);
  }
}
