import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../domain/entities/note.dart';
import '../controllers/notes_controller.dart';
import '../widgets/note_list.dart';
import '../widgets/notes_header_widget.dart';
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: inputBg.withOpacity(isDark ? 0.6 : 0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF8C98A9),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                              style: TextStyle(fontSize: 14, color: textColor),
                              decoration: const InputDecoration(
                                hintText: 'Search notes...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF8C98A9),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A30) : const Color(0xFFEAEAEE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '⌘K',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: inputBg.withOpacity(isDark ? 0.6 : 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor.withOpacity(0.5)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        color: textColor,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              if (availableTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                // 1.5 Horizontal Tag Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTag = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            gradient: _selectedTag == null
                                ? const LinearGradient(
                                    colors: [AppColors.primaryPurple, AppColors.primaryPink],
                                  )
                                : null,
                            color: _selectedTag == null
                                ? null
                                : inputBg.withOpacity(isDark ? 0.6 : 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedTag == null
                                  ? Colors.transparent
                                  : borderColor.withOpacity(0.3),
                            ),
                            boxShadow: _selectedTag == null
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryPink.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            'All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _selectedTag == null ? Colors.white : textColor,
                            ),
                          ),
                        ),
                      ),
                      ...availableTags.map((tag) {
                        final isSelected = _selectedTag == tag;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTag = isSelected ? null : tag;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [AppColors.primaryPurple, AppColors.primaryPink],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : inputBg.withOpacity(isDark ? 0.6 : 0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : borderColor.withOpacity(0.3),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryPink.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : textColor,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // 2. Sorting & Layout Toggle Controls Sub-header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      setState(() {
                        _selectedSort = val;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sort by: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8C98A9),
                          ),
                        ),
                        Text(
                          _selectedSort,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: textColor,
                        ),
                      ],
                    ),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'Last edited',
                        child: Text('Last edited'),
                      ),
                      PopupMenuItem(
                        value: 'Title',
                        child: Text('Title'),
                      ),
                      PopupMenuItem(
                        value: 'Date created',
                        child: Text('Date created'),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isGridView = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: !_isGridView
                                  ? AppColors.lightLavender
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.format_list_bulleted_rounded,
                              size: 18,
                              color: !_isGridView
                                  ? AppColors.primaryPurple
                                  : const Color(0xFF8C98A9),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isGridView = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _isGridView
                                  ? AppColors.lightLavender
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.grid_view_rounded,
                              size: 18,
                              color: _isGridView
                                  ? AppColors.primaryPurple
                                  : const Color(0xFF8C98A9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

