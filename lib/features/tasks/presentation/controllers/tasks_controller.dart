import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';

class TasksController extends ChangeNotifier {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final ToggleTaskCompletionUseCase toggleTaskCompletionUseCase;

  List<TaskItem> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TasksController({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleTaskCompletionUseCase,
  });

  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks(String noteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await getTasksUseCase(noteId);
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTask(String noteId, TaskItem task) async {
    try {
      await toggleTaskCompletionUseCase(noteId, task);
      await NotesController.instance.loadFromDatabase();
      await loadTasks(noteId);
    } catch (e) {
      _error = 'Failed to toggle task: $e';
      notifyListeners();
    }
  }

  Future<void> addTask(String noteId, String text) async {
    try {
      await createTaskUseCase(noteId, text);
      await NotesController.instance.loadFromDatabase();
      await loadTasks(noteId);
    } catch (e) {
      _error = 'Failed to add task: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String noteId, TaskItem task) async {
    try {
      await deleteTaskUseCase(noteId, task);
      await NotesController.instance.loadFromDatabase();
      await loadTasks(noteId);
    } catch (e) {
      _error = 'Failed to delete task: $e';
      notifyListeners();
    }
  }
}
