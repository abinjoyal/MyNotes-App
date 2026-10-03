import '../entities/task.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call(String noteId, TaskItem task) async {
    await repository.deleteTaskFromNote(noteId, task);
  }
}
