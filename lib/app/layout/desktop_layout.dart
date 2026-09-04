import 'package:flutter/material.dart';
import 'sidebar_layout.dart';
import '../constants/app_colors.dart';
import '../../features/folders/presentation/screens/folders_screen.dart';
import '../../features/notes/domain/entities/note.dart';
import '../../features/notes/presentation/controllers/notes_controller.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/pin/presentation/screens/pinned_notes_screen.dart';

class DesktopLayout extends StatefulWidget {
  final Widget? notesListWidget;
  final Widget? editorWidget;

  const DesktopLayout({
    super.key,
    this.notesListWidget,
    this.editorWidget,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  String _activeRoute = 'all_notes';
  Note? _selectedNote;

  Widget _buildMiddlePane() {
    if (widget.notesListWidget != null) {
      return widget.notesListWidget!;
    }
    if (_activeRoute == 'new_note' || _activeRoute == 'edit_note') {
      return NoteEditorScreen(
        note: _selectedNote,
        onClose: () {
          setState(() {
            _selectedNote = null;
            _activeRoute = 'all_notes';
          });
        },
        onSave: (title, content, color, tags, isPinned) {
          NotesController.instance.saveNote(
            id: _selectedNote?.id,
            title: title,
            content: content,
            indicatorColor: color,
            tags: tags,
            isPinned: isPinned,
            folderName: _selectedNote?.folderName,
          );
          setState(() {
            _selectedNote = null;
            _activeRoute = 'all_notes';
          });
        },
      );
    }
    if (_activeRoute == 'pinned') {
      return PinnedNotesScreen(
        onNoteSelect: (note) {
          setState(() {
            _selectedNote = note;
            _activeRoute = 'edit_note';
          });
        },
      );
    }
    if (_activeRoute == 'folders' || _activeRoute.startsWith('folder:')) {
      final selectedFolder = _activeRoute.contains(':')
          ? _activeRoute.split(':')[1]
          : null;
      return FoldersScreen(
        selectedFolderName: selectedFolder,
        onNoteSelect: (note) {
          setState(() {
            _selectedNote = note;
            _activeRoute = 'edit_note';
          });
        },
      );
    }
    if (_activeRoute == 'all_notes' ||
        _activeRoute == 'tasks' ||
        _activeRoute == 'trash') {
      return NotesScreen(
        activeRoute: _activeRoute,
        onNoteSelect: (note) {
          setState(() {
            _selectedNote = note;
            _activeRoute = 'edit_note';
          });
        },
      );
    }
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          'Active Section: ${_activeRoute.toUpperCase()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          SidebarLayout(
            activeRoute: _activeRoute,
            onNavigate: (route) {
              setState(() {
                if (route.startsWith('new_note')) {
                  if (route.contains(':')) {
                    final template = route.split(':')[1];
                    _selectedNote = NotesController.instance.createTemplateNote(template);
                  } else {
                    _selectedNote = null;
                  }
                  _activeRoute = 'new_note';
                } else {
                  _activeRoute = route;
                }
              });
            },
          ),

          // Divider
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.divider),

          // Main View (Full Width Notes Screen or Split View with Editor)
          Expanded(
            child: widget.editorWidget != null
                ? Row(
                    children: [
                      // Middle Pane (Notes List)
                      Expanded(
                        flex: 2,
                        child: _buildMiddlePane(),
                      ),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.divider,
                      ),
                      // Right Pane (Note Editor)
                      Expanded(
                        flex: 3,
                        child: widget.editorWidget!,
                      ),
                    ],
                  )
                : _buildMiddlePane(),
          ),
        ],
      ),
    );
  }
}

