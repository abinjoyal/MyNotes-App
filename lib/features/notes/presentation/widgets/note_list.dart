import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import '../controllers/notes_controller.dart';
import 'note_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  final bool isGridView;
  final Function(Note)? onNoteSelect;
  final String activeRoute;
  final VoidCallback? onActionTap;

  const NoteList({
    super.key,
    required this.notes,
    this.isGridView = false,
    this.onNoteSelect,
    this.activeRoute = 'all_notes',
    this.onActionTap,
  });

  static final List<Note> sampleNotes = [];

  Widget _buildEmptyState(BuildContext context) {
    IconData iconData = Icons.note_add_rounded;
    Color iconColor = const Color(0xFF635BFF);
    Color bgColor = const Color(0xFFEEECFF);
    String title = 'No Notes Found';
    String subtitle =
        'Click "+ New Note" in the sidebar to create your first note.';
    String? buttonText = 'Create New Note';

    if (activeRoute == 'pinned') {
      iconData = Icons.push_pin_rounded;
      iconColor = const Color(0xFF635BFF);
      bgColor = const Color(0xFFEEECFF);
      title = 'No Pinned Notes Yet';
      subtitle = 'Pin your important notes to keep them at your fingertips.';
      buttonText = null;
    } else if (activeRoute == 'tasks') {
      iconData = Icons.check_box_rounded;
      iconColor = const Color(0xFF00C853);
      bgColor = const Color(0xFFE8F8EE);
      title = 'No Tasks Found';
      subtitle =
          'Add checklist items (- [ ]) inside your notes to track tasks here.';
      buttonText = 'Create Task Checklist';
    } else if (activeRoute == 'folder') {
      iconData = Icons.folder_open_rounded;
      iconColor = const Color(0xFF635BFF);
      bgColor = const Color(0xFFEEECFF);
      title = 'Folder is Empty';
      subtitle = 'Create a new note in this folder to get started.';
      buttonText = 'Create New Note';
    } else if (activeRoute == 'trash') {
      iconData = Icons.delete_outline_rounded;
      iconColor = const Color(0xFFFF4B4B);
      bgColor = const Color(0xFFFFEEEE);
      title = 'Trash is Empty';
      subtitle =
          'Deleted notes will appear here before being permanently removed.';
      buttonText = null;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF0F0F3);
    final titleColor = isDark
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF1D2939);
    final subtitleColor = isDark
        ? const Color(0xFF98A2B3)
        : const Color(0xFF667085);
    final iconCircleBg = isDark ? iconColor.withOpacity(0.2) : bgColor;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: iconCircleBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 38, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4, color: subtitleColor),
            ),
            if (buttonText != null && onActionTap != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onActionTap,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return _buildEmptyState(context);
    }

    final isTrashRoute = activeRoute == 'trash';

    if (isGridView) {
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 360,
          mainAxisExtent: 180,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            isTrash: isTrashRoute,
            onTap: isTrashRoute
                ? null
                : () {
                    if (onNoteSelect != null) {
                      onNoteSelect!(note);
                    }
                  },
            onPinToggle: isTrashRoute
                ? null
                : () {
                    NotesController.instance.togglePin(note.id);
                  },
            onDelete: isTrashRoute
                ? null
                : () {
                    NotesController.instance.deleteNote(note.id);
                  },
            onRestore: () {
              NotesController.instance.restoreFromTrash(note.id);
            },
            onPermanentDelete: () {
              NotesController.instance.permanentlyDeleteFromTrash(note.id);
            },
          ).animate()
           .fade(duration: 300.ms, delay: (index * 30).ms)
           .slideY(begin: 0.05, duration: 300.ms, curve: Curves.easeOutQuad);
        },
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          isTrash: isTrashRoute,
          onTap: isTrashRoute
              ? null
              : () {
                  if (onNoteSelect != null) {
                    onNoteSelect!(note);
                  }
                },
          onPinToggle: isTrashRoute
              ? null
              : () {
                  NotesController.instance.togglePin(note.id);
                },
          onDelete: isTrashRoute
              ? null
              : () {
                  NotesController.instance.deleteNote(note.id);
                },
          onRestore: () {
            NotesController.instance.restoreFromTrash(note.id);
          },
          onPermanentDelete: () {
            NotesController.instance.permanentlyDeleteFromTrash(note.id);
          },
        ).animate()
         .fade(duration: 300.ms, delay: (index * 30).ms)
         .slideX(begin: 0.05, duration: 300.ms, curve: Curves.easeOutQuad);
      },
    );
  }
}
