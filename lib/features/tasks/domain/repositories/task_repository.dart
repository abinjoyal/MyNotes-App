import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<TaskItem>> getTasksForNote(String noteId);
  Future<void> toggleTaskCompletion(String noteId, TaskItem task);
  Future<void> addTaskToNote(String noteId, String taskText);
  Future<void> deleteTaskFromNote(String noteId, TaskItem task);
}
