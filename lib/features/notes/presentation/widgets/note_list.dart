import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import '../controllers/notes_controller.dart';
import 'note_card.dart';

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
    String subtitle = 'Click "+ New Note" in the sidebar to create your first note.';
    String? buttonText = '+ Create New Note';

    if (activeRoute == 'pinned') {
      iconData = Icons.push_pin_rounded;
      iconColor = const Color(0xFF635BFF);
      bgColor = const Color(0xFFEEECFF);
      title = 'No Pinned Notes Yet';
      subtitle = 'Pin your important notes to keep them at your fingertips.';
      buttonText = 'View All Notes';
    } else if (activeRoute == 'tasks') {
      iconData = Icons.check_box_rounded;
      iconColor = const Color(0xFF00C853);
      bgColor = const Color(0xFFE8F8EE);
      title = 'No Tasks Found';
      subtitle = 'Add checklist items (- [ ]) inside your notes to track tasks here.';
      buttonText = '+ Create Task Checklist';
    } else if (activeRoute == 'trash') {
      iconData = Icons.delete_outline_rounded;
      iconColor = const Color(0xFFFF4B4B);
      bgColor = const Color(0xFFFFEEEE);
      title = 'Trash is Empty';
      subtitle = 'Deleted notes will appear here before being permanently removed.';
      buttonText = null;
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F3)),
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
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 38,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2939),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF667085),
              ),
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
            onTap: () {
              if (onNoteSelect != null) {
                onNoteSelect!(note);
              }
            },
            onPinToggle: () {
              NotesController.instance.togglePin(note.id);
            },
            onDelete: () {
              NotesController.instance.deleteNote(note.id);
            },
          );
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
          onTap: () {
            if (onNoteSelect != null) {
              onNoteSelect!(note);
            }
          },
          onPinToggle: () {
            NotesController.instance.togglePin(note.id);
          },
        );
      },
    );
  }
}

