import '../entities/trash_item.dart';
import '../repositories/trash_repository.dart';

class GetTrashItemsUseCase {
  final TrashRepository repository;

  GetTrashItemsUseCase(this.repository);

  Future<List<TrashItem>> call() async {
    return await repository.getTrashItems();
  }
}
