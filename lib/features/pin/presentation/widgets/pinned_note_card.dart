import 'package:flutter/material.dart';
import '../../domain/entities/pinned_note.dart';

class PinnedNoteCard extends StatelessWidget {
  final PinnedNote pinnedNote;
  final VoidCallback onUnpin;
  final VoidCallback onTap;

  const PinnedNoteCard({
    super.key,
    required this.pinnedNote,
    required this.onUnpin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.push_pin, color: Colors.blue),
        title: Text('Pinned Note: ${pinnedNote.noteId}'),
        subtitle: Text('Pinned at: ${pinnedNote.pinnedAt.toLocal().toString().split('.')[0]}'),
        trailing: IconButton(
          icon: const Icon(Icons.push_pin_outlined, color: Colors.grey),
          onPressed: onUnpin,
          tooltip: 'Unpin Note',
        ),
      ),
    );
  }
}
