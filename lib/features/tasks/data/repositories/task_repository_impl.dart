import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../../../../core/database/database.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl([AppDatabase? db])
    : localDataSource = TaskLocalDataSourceImpl(
        database: db ?? AppDatabase.instance,
      );

  TaskRepositoryImpl.withDataSource(this.localDataSource);

  @override
  Future<List<TaskItem>> getTasksForNote(String noteId) async {
    return await localDataSource.getTasksForNote(noteId);
  }

  @override
  Future<void> toggleTaskCompletion(String noteId, TaskItem task) async {
    await localDataSource.toggleTaskCompletion(noteId, task);
  }

  @override
  Future<void> addTaskToNote(String noteId, String taskText) async {
    await localDataSource.addTaskToNote(noteId, taskText);
  }

  @override
  Future<void> deleteTaskFromNote(String noteId, TaskItem task) async {
    await localDataSource.deleteTaskFromNote(noteId, task);
  }
}
