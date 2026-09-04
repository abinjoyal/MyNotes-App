import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../domain/entities/note.dart';
import '../controllers/notes_controller.dart';
import '../widgets/note_list.dart';

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
  bool _isGridView = false;
  String _selectedSort = 'Last edited';
  String _searchQuery = '';
  String? _selectedTag;
  final NotesController _controller = NotesController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onNotesChanged);
    super.dispose();
  }

  void _onNotesChanged() {
    if (mounted) setState(() {});
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
        : _controller.notes;

    final filteredNotes = allNotes.where((note) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.tags.any((t) => t.toLowerCase().contains(query));

      final matchesTag = _selectedTag == null || note.tags.contains(_selectedTag);
      return matchesQuery && matchesTag;
    }).toList();

    final availableTags = _controller.allTags;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. Section Title & Subtitle Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            headerInfo['title']!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.lightLavender,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${allNotes.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        headerInfo['subtitle']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Top Search Bar & Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEAEAEE)),
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
                              color: const Color(0xFFEAEAEE),
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
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEAEAEE)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.darkText,
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
                            color: _selectedTag == null
                                ? AppColors.primaryPurple
                                : const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedTag == null
                                  ? AppColors.primaryPurple
                                  : const Color(0xFFEAEAEE),
                            ),
                          ),
                          child: Text(
                            'All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _selectedTag == null ? Colors.white : AppColors.darkText,
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
                              color: isSelected
                                  ? AppColors.primaryPurple
                                  : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryPurple
                                    : const Color(0xFFEAEAEE),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.darkText,
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppColors.darkText,
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
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(8),
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
    );
  }
}

