import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/database/database.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import 'tasks_controller.dart';

final tasksProvider = ChangeNotifierProvider<TasksController>((ref) {
  final repository = TaskRepositoryImpl(AppDatabase.instance);

  return TasksController(
    getTasksUseCase: GetTasksUseCase(repository),
    createTaskUseCase: CreateTaskUseCase(repository),
    deleteTaskUseCase: DeleteTaskUseCase(repository),
    toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase(repository),
  );
});
