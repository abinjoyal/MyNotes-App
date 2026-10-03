import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<void> call(String noteId, String taskText) async {
    await repository.addTaskToNote(noteId, taskText);
  }
}
