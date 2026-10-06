import 'package:flutter/material.dart';
import 'package:notes/features/notes/domain/entities/note.dart';
import 'package:notes/features/notes/presentation/screens/notes_screen.dart';

class PinnedNotesScreen extends StatelessWidget {
  final Function(Note)? onNoteSelect;

  const PinnedNotesScreen({super.key, this.onNoteSelect});

  @override
  Widget build(BuildContext context) {
    return NotesScreen(activeRoute: 'pinned', onNoteSelect: onNoteSelect);
  }
}
