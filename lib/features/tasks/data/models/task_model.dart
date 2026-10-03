import '../../domain/entities/task.dart';

class TaskModel extends TaskItem {
  const TaskModel({
    required super.index,
    required super.text,
    required super.isCompleted,
    super.tag,
    required super.time,
    super.noteId,
  });

  factory TaskModel.fromMarkdownLine(String line, int index, {String? noteId}) {
    final trimmed = line.trim();
    final isDone = trimmed.startsWith('- [x] ') || trimmed.startsWith('- [X] ');
    String rawText = (trimmed.startsWith('- [ ] ') || trimmed.startsWith('- [x] ') || trimmed.startsWith('- [X] '))
        ? trimmed.substring(6).trim()
        : trimmed;

    String? tag;
    final tagMatch = RegExp(r'#(\w+)').firstMatch(rawText);
    if (tagMatch != null) {
      tag = tagMatch.group(1);
      rawText = rawText.replaceAll(RegExp(r'#\w+'), '').trim();
    }

    return TaskModel(
      index: index,
      text: rawText.isEmpty ? 'Untitled Task' : rawText,
      isCompleted: isDone,
      tag: tag,
      time: 'Today',
      noteId: noteId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'text': text,
      'isCompleted': isCompleted,
      'tag': tag,
      'time': time,
      'noteId': noteId,
    };
  }
}
