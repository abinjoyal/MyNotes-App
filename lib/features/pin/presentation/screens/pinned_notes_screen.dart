import 'package:flutter/material.dart';
import 'package:mynotes/features/notes/domain/entities/note.dart';
import 'package:mynotes/features/notes/presentation/screens/notes_screen.dart';


class PinnedNotesScreen extends StatelessWidget {
  final Function(Note)? onNoteSelect;

  const PinnedNotesScreen({
    super.key,
    this.onNoteSelect,
  });

  @override
  Widget build(BuildContext context) {
    return NotesScreen(
      activeRoute: 'pinned',
      onNoteSelect: onNoteSelect,
    );
  }
}
