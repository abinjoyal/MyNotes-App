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
    Color iconColor = const Color(0xFF635BFF);
    String title = 'No Notes Found';
    String subtitle =
        'Click "+ New Note" in the sidebar to create your first note.';
    String? buttonText = 'Create New Note';

    if (activeRoute == 'pinned') {
      iconColor = const Color(0xFF635BFF);
      title = 'No Pinned Notes Yet';
      subtitle = 'Pin your important notes to keep them at \nyour fingertips.';
      buttonText = null;
    } else if (activeRoute == 'tasks') {
      iconColor = const Color(0xFF00C853);
      title = 'No Tasks Found';
      subtitle =
          'Add checklist items (- [ ]) inside your notes to track tasks here.';
      buttonText = 'Create Task Checklist';
    } else if (activeRoute == 'folder') {
      iconColor = const Color(0xFF635BFF);
      title = 'Folder is Empty';
      subtitle = 'Create a new note in this folder to get started.';
      buttonText = 'Create New Note';
    } else if (activeRoute == 'trash') {
      iconColor = const Color(0xFFFF4B4B);
      title = 'Trash is Empty';
      subtitle =
          'Deleted notes will appear here before being permanently removed.';
      buttonText = null;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF1D2939);
    final subtitleColor = isDark
        ? const Color(0xFF98A2B3)
        : const Color(0xFF667085);

    if (activeRoute == 'trash') {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 180, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your trash is empty',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Deleted notes will appear here before being \npermanently removed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (activeRoute == 'folder') {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.4, color: subtitleColor),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4, color: subtitleColor),
            ),
            if (buttonText != null && onActionTap != null) ...[
              const SizedBox(height: 20),
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
              )
              .animate()
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
            )
            .animate()
            .fade(duration: 300.ms, delay: (index * 30).ms)
            .slideX(begin: 0.05, duration: 300.ms, curve: Curves.easeOutQuad);
      },
    );
  }
}
