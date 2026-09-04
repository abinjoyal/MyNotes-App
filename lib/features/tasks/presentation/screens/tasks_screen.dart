import 'package:flutter/material.dart';
import 'package:mynotes/features/notes/domain/entities/note.dart' as entity;
import '../widgets/tasks_checklist_view.dart';

class TasksScreen extends StatelessWidget {
  final Function(entity.Note)? onNoteSelect;

  const TasksScreen({super.key, this.onNoteSelect});

  @override
  Widget build(BuildContext context) {
    return TasksChecklistView(
      onNoteSelect: onNoteSelect,
    );
  }
}

