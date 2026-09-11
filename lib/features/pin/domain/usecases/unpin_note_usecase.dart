import '../repositories/pin_repository.dart';

class UnpinNoteUseCase {
  final PinRepository repository;

  UnpinNoteUseCase(this.repository);

  Future<void> call(String noteId) async {
    return await repository.unpinNote(noteId);
  }
}
