class TaskItem {
  final int index;
  final String text;
  final bool isCompleted;
  final String? tag;
  final String time;
  final String? noteId;

  const TaskItem({
    required this.index,
    required this.text,
    required this.isCompleted,
    this.tag,
    required this.time,
    this.noteId,
  });

  TaskItem copyWith({
    int? index,
    String? text,
    bool? isCompleted,
    String? tag,
    String? time,
    String? noteId,
  }) {
    return TaskItem(
      index: index ?? this.index,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      tag: tag ?? this.tag,
      time: time ?? this.time,
      noteId: noteId ?? this.noteId,
    );
  }
}
