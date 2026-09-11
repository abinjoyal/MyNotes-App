import '../repositories/pin_repository.dart';

class PinNoteUseCase {
  final PinRepository repository;

  PinNoteUseCase(this.repository);

  Future<void> call(String noteId) async {
    return await repository.pinNote(noteId);
  }
}
