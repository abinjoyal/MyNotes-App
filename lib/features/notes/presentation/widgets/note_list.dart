import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import 'note_card.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  final bool isGridView;
  final Function(Note)? onNoteSelect;

  const NoteList({
    super.key,
    required this.notes,
    this.isGridView = false,
    this.onNoteSelect,
  });

  static final List<Note> sampleNotes = [
    const Note(
      id: '1',
      title: 'Figma Typography Guide',
      content:
          'Typography is the foundation of great design. It establishes hierarchy, improves readability...',
      indicatorColor: Color(0xFF635BFF),
      tags: ['#figma', '#learning'],
      updatedAt: '2 min ago',
      isPinned: true,
    ),
    const Note(
      id: '2',
      title: 'Flutter Workout Screen Ideas',
      content:
          'Some ideas for improving the workout details screen with better UI/UX and animations.',
      indicatorColor: Color(0xFF4C6FFF),
      tags: ['#flutter'],
      updatedAt: '1 hour ago',
      isPinned: false,
    ),
    const Note(
      id: '3',
      title: 'AI Food Scanner Project',
      content:
          'YOLOv8 for food detection + nutrition database integration plan and architecture.',
      indicatorColor: Color(0xFFFF4B4B),
      tags: ['#project'],
      updatedAt: 'Yesterday',
      isPinned: false,
    ),
    const Note(
      id: '4',
      title: 'Daily Note - Sep 3',
      content:
          "Today's goals and notes\n• Complete notes UI\n• Add command palette...",
      indicatorColor: Color(0xFFFFB020),
      tags: ['#daily'],
      updatedAt: 'Yesterday',
      isPinned: false,
    ),
    const Note(
      id: '5',
      title: 'Design System Checklist',
      content:
          'Colors, typography, spacing, components: everything in one place.',
      indicatorColor: Color(0xFF00C853),
      tags: ['#uiux'],
      updatedAt: 'Sep 2, 2026',
      isPinned: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        );
      },
    );
  }
}

