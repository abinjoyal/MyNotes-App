import '../entities/pinned_note.dart';
import '../repositories/pin_repository.dart';

class GetPinnedNotes {
  final PinRepository repository;

  GetPinnedNotes(this.repository);

  Future<List<PinnedNote>> call() async {
    return await repository.getPinnedNotes();
  }
}
