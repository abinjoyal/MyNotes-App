import 'package:flutter/material.dart';
import 'package:notes/app/theme/app_theme_colors.dart';

import '../../domain/entities/note.dart';
import '../widgets/note_editor.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NoteEditorScreen extends StatelessWidget {
  final Note? note;
  final Function(
    String title,
    String content,
    Color color,
    List<String> tags,
    bool isPinned,
  )?
  onSave;
  final VoidCallback? onClose;

  const NoteEditorScreen({super.key, this.note, this.onSave, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.scaffoldBg,
      body: SafeArea(
        child: NoteEditor(initialNote: note, onSave: onSave, onClose: onClose)
            .animate()
            .fade(duration: 250.ms)
            .slideY(begin: 0.03, duration: 250.ms, curve: Curves.easeOut),
      ),
    );
  }
}
