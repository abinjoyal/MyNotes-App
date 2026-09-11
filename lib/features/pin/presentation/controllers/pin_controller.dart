import 'package:flutter/material.dart';
import '../../domain/entities/pinned_note.dart';
import '../../domain/usecases/get_pinned_notes.dart';
import '../../domain/usecases/pin_note_usecase.dart';
import '../../domain/usecases/unpin_note_usecase.dart';

class PinController extends ChangeNotifier {
  final GetPinnedNotes getPinnedNotesUseCase;
  final PinNoteUseCase pinNoteUseCase;
  final UnpinNoteUseCase unpinNoteUseCase;

  PinController({
    required this.getPinnedNotesUseCase,
    required this.pinNoteUseCase,
    required this.unpinNoteUseCase,
  });

  List<PinnedNote> _pinnedNotes = [];
  List<PinnedNote> get pinnedNotes => _pinnedNotes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadPinnedNotes() async {
    _isLoading = true;
    notifyListeners();

    _pinnedNotes = await getPinnedNotesUseCase();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pinNote(String noteId) async {
    await pinNoteUseCase(noteId);
    await loadPinnedNotes();
  }

  Future<void> unpinNote(String noteId) async {
    await unpinNoteUseCase(noteId);
    await loadPinnedNotes();
  }
}
