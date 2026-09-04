import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import '../widgets/note_editor.dart';

class NoteEditorScreen extends StatelessWidget {
  final Note? note;
  final Function(
    String title,
    String content,
    Color color,
    List<String> tags,
    bool isPinned,
  )? onSave;
  final VoidCallback? onClose;

  const NoteEditorScreen({
    super.key,
    this.note,
    this.onSave,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NoteEditor(
          initialNote: note,
          onSave: onSave,
          onClose: onClose,
        ),
      ),
    );
  }
}

