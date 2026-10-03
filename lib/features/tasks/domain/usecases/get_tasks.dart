import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<List<TaskItem>> call(String noteId) async {
    return await repository.getTasksForNote(noteId);
  }
}
