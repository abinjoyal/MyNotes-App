import '../repositories/trash_repository.dart';

class RestoreNoteUseCase {
  final TrashRepository repository;

  RestoreNoteUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.restoreNote(id);
  }
}
