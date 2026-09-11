import '../../domain/entities/pinned_note.dart';
import '../../domain/repositories/pin_repository.dart';
import '../datasources/pin_local_datasource.dart';

class PinRepositoryImpl implements PinRepository {
  final PinLocalDataSource localDataSource;

  PinRepositoryImpl(this.localDataSource);

  @override
  Future<List<PinnedNote>> getPinnedNotes() async {
    return await localDataSource.getPinnedNotes();
  }

  @override
  Future<void> pinNote(String noteId) async {
    return await localDataSource.pinNote(noteId);
  }

  @override
  Future<void> unpinNote(String noteId) async {
    return await localDataSource.unpinNote(noteId);
  }
}
