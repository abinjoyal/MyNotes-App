import 'package:flutter/material.dart';
import 'package:mynotes/features/pin/domain/entities/pinned_note.dart';
import '../controllers/pin_controller.dart';
import '../widgets/pinned_note_card.dart';

class PinnedNotesScreen extends StatefulWidget {
  final PinController controller;
  final Function(PinnedNote)? onNoteSelect;

  const PinnedNotesScreen({
    super.key,
    required this.controller,
    this.onNoteSelect,
  });

  @override
  State<PinnedNotesScreen> createState() => _PinnedNotesScreenState();
}

class _PinnedNotesScreenState extends State<PinnedNotesScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadPinnedNotes();
    widget.controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinned Notes'),
      ),
      body: widget.controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.controller.pinnedNotes.isEmpty
              ? const Center(child: Text('No pinned notes yet.'))
              : ListView.builder(
                  itemCount: widget.controller.pinnedNotes.length,
                  itemBuilder: (context, index) {
                    final pinnedNote = widget.controller.pinnedNotes[index];
                    return PinnedNoteCard(
                      pinnedNote: pinnedNote,
                      onUnpin: () {
                        widget.controller.unpinNote(pinnedNote.noteId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Note unpinned')),
                        );
                      },
                      onTap: () {
                        if (widget.onNoteSelect != null) {
                          widget.onNoteSelect!(pinnedNote);
                        }
                      },
                    );
                  },
                ),
    );
  }
}
