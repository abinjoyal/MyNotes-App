import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleTaskCompletionUseCase {
  final TaskRepository repository;

  ToggleTaskCompletionUseCase(this.repository);

  Future<void> call(String noteId, TaskItem task) async {
    await repository.toggleTaskCompletion(noteId, task);
  }
}
