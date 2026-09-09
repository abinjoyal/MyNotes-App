import '../repositories/trash_repository.dart';

class DeleteNotePermanentlyUseCase {
  final TrashRepository repository;

  DeleteNotePermanentlyUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteNotePermanently(id);
  }
}
