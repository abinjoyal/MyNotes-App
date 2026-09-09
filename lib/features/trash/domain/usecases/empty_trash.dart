import '../repositories/trash_repository.dart';

class EmptyTrashUseCase {
  final TrashRepository repository;

  EmptyTrashUseCase(this.repository);

  Future<void> call() async {
    return await repository.emptyTrash();
  }
}
