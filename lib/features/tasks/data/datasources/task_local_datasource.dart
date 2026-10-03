import '../../../../core/database/database.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasksForNote(String noteId);
  Future<void> toggleTaskCompletion(String noteId, TaskItem task);
  Future<void> addTaskToNote(String noteId, String taskText);
  Future<void> deleteTaskFromNote(String noteId, TaskItem task);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final AppDatabase database;

  TaskLocalDataSourceImpl({required this.database});

  @override
  Future<List<TaskModel>> getTasksForNote(String noteId) async {
    final notes = await database.getAllNotes();
    final note = notes.firstWhere(
      (n) => n.id == noteId,
      orElse: () => throw Exception('Note not found'),
    );

    final lines = note.content.split('\n');
    final List<TaskModel> tasks = [];
    int idx = 0;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- [ ] ') ||
          trimmed.startsWith('- [x] ') ||
          trimmed.startsWith('- [X] ')) {
        tasks.add(TaskModel.fromMarkdownLine(line, idx, noteId: noteId));
        idx++;
      }
    }
    return tasks;
  }

  @override
  Future<void> toggleTaskCompletion(String noteId, TaskItem task) async {
    final notes = await database.getAllNotes();
    final note = notes.firstWhere((n) => n.id == noteId);
    final lines = note.content.split('\n');
    int matchIdx = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('- [ ] ') ||
          line.startsWith('- [x] ') ||
          line.startsWith('- [X] ')) {
        if (matchIdx == task.index) {
          final prefix = task.isCompleted ? '- [ ] ' : '- [x] ';
          final contentPart = line.substring(6);
          lines[i] = '$prefix$contentPart';
          break;
        }
        matchIdx++;
      }
    }

    final updated = note.copyWith(content: lines.join('\n'));
    await database.saveNote(updated);
  }

  @override
  Future<void> addTaskToNote(String noteId, String taskText) async {
    final notes = await database.getAllNotes();
    final note = notes.firstWhere((n) => n.id == noteId);
    final newContent = note.content.isEmpty
        ? '- [ ] $taskText'
        : '${note.content}\n- [ ] $taskText';

    final updated = note.copyWith(content: newContent);
    await database.saveNote(updated);
  }

  @override
  Future<void> deleteTaskFromNote(String noteId, TaskItem task) async {
    final notes = await database.getAllNotes();
    final note = notes.firstWhere((n) => n.id == noteId);
    final lines = note.content.split('\n');
    int matchIdx = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('- [ ] ') ||
          line.startsWith('- [x] ') ||
          line.startsWith('- [X] ')) {
        if (matchIdx == task.index) {
          lines.removeAt(i);
          break;
        }
        matchIdx++;
      }
    }

    final updated = note.copyWith(content: lines.join('\n'));
    await database.saveNote(updated);
  }
}
