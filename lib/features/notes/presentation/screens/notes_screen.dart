import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../domain/entities/note.dart';
import '../controllers/notes_controller.dart';
import '../widgets/note_list.dart';
import '../widgets/notes_header_widget.dart';
import '../widgets/notes_filter_bar_widget.dart';
import '../widgets/notes_tag_list_widget.dart';
import '../../../tasks/presentation/widgets/tasks_checklist_view.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

class NotesScreen extends StatefulWidget {
  final Function(Note)? onNoteSelect;
  final String activeRoute;

  const NotesScreen({
    super.key,
    this.onNoteSelect,
    this.activeRoute = 'all_notes',
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late bool _isGridView;
  String _selectedSort = 'Last edited';
  String _searchQuery = '';
  String? _selectedTag;
  final NotesController _controller = NotesController.instance;
  final SettingsController _settingsController = SettingsController.instance;

  @override
  void initState() {
    super.initState();
    _isGridView = _settingsController.isGridView;
    _controller.addListener(_onNotesChanged);
    _settingsController.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onNotesChanged);
    _settingsController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onNotesChanged() {
    if (mounted) setState(() {});
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        _isGridView = _settingsController.isGridView;
      });
    }
  }

  Map<String, String> _getHeaderInfo() {
    switch (widget.activeRoute) {
      case 'pinned':
        return {
          'title': '📌 Pinned Notes',
          'subtitle': 'Important items pinned for quick reference.',
        };
      case 'tasks':
        return {
          'title': '✅ Tasks Checklist',
          'subtitle': 'Checklists and task notes.',
        };
      case 'trash':
        return {
          'title': '🗑️ Trash',
          'subtitle': 'Deleted items waiting for cleanup.',
        };
      default:
        return {
          'title': '📝 All Notes',
          'subtitle': 'Manage and organize all your personal workspace notes.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerInfo = _getHeaderInfo();
    final allNotes = widget.activeRoute == 'pinned'
        ? _controller.pinnedNotes
        : (widget.activeRoute == 'trash'
            ? _controller.trashedNotes
            : _controller.regularNotes);

    final filteredNotes = allNotes.where((note) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.tags.any((t) => t.toLowerCase().contains(query));

      final matchesTag = _selectedTag == null || note.tags.contains(_selectedTag);
      return matchesQuery && matchesTag;
    }).toList();

    final availableTags = _controller.allTags;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkScaffoldBackground : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final inputBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FA);
    final borderColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAEAEE);

    if (widget.activeRoute == 'tasks') {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: TasksChecklistView(
              onNoteSelect: widget.onNoteSelect,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [const Color(0xFF1A1A24), const Color(0xFF121212)]
              : [const Color(0xFFF8F9FF), const Color(0xFFF1F3F6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: widget.activeRoute != 'trash' ? Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryPurple, AppColors.primaryPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPink.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              if (widget.onNoteSelect != null) {
                Note templateNote = _controller.createTemplateNote(
                  widget.activeRoute == 'tasks' ? 'checklist' : 'blank',
                );
                widget.onNoteSelect!(templateNote);
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ) : null,
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. Section Title & Subtitle Header
              NotesHeaderWidget(
                title: headerInfo['title']!,
                subtitle: headerInfo['subtitle']!,
                noteCount: allNotes.length,
                textColor: textColor,
                activeRoute: widget.activeRoute,
                onEmptyTrash: () {
                  _controller.emptyTrash();
                },
              ),
              const SizedBox(height: 16),

              // 1. Top Search Bar & Filter Row
              NotesSearchBarWidget(
                isDark: isDark,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onFilterTap: () {},
              ),

              if (availableTags.isNotEmpty)
                NotesTagListWidget(
                  availableTags: availableTags,
                  selectedTag: _selectedTag,
                  onTagSelect: (tag) {
                    setState(() {
                      _selectedTag = tag;
                    });
                  },
                  isDark: isDark,
                ),

              const SizedBox(height: 14),

              // 2. Sorting & Layout Toggle Controls Sub-header
              NotesLayoutControlsWidget(
                isDark: isDark,
                selectedSort: _selectedSort,
                onSortChanged: (val) {
                  setState(() {
                    _selectedSort = val;
                  });
                },
                isGridView: _isGridView,
                onLayoutChanged: (isGrid) {
                  setState(() {
                    _isGridView = isGrid;
                  });
                },
              ),

              const SizedBox(height: 16),

              // 3. Notes List View / Contextual Empty State
              Expanded(
                child: NoteList(
                  notes: filteredNotes,
                  isGridView: _isGridView,
                  activeRoute: widget.activeRoute,
                  onNoteSelect: widget.onNoteSelect,
                  onActionTap: () {
                    if (widget.onNoteSelect != null) {
                      Note templateNote = _controller.createTemplateNote(
                        widget.activeRoute == 'tasks' ? 'checklist' : 'blank',
                      );
                      widget.onNoteSelect!(templateNote);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

