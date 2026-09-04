import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../domain/entities/note.dart';
import '../widgets/note_list.dart';

class NotesScreen extends StatefulWidget {
  final Function(Note)? onNoteSelect;

  const NotesScreen({
    super.key,
    this.onNoteSelect,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isGridView = false;
  String _selectedSort = 'Last edited';
  String _searchQuery = '';
  List<Note> _notes = NoteList.sampleNotes;

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notes.where((note) {
      final query = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.tags.any((t) => t.toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

                          // ⌘K Shortcut Badge
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

                  // Filter Icon Button
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

              const SizedBox(height: 16),

              // 2. Sorting & Layout Toggle Controls Sub-header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sort By Selector Dropdown
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

                  // View Toggle Buttons (List View / Grid View)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // List View Mode Button
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

                        // Grid View Mode Button
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

              // 3. Notes List View
              Expanded(
                child: filteredNotes.isEmpty
                    ? const Center(
                        child: Text(
                          'No notes found',
                          style: TextStyle(color: Color(0xFF8C98A9)),
                        ),
                      )
                    : NoteList(
                        notes: filteredNotes,
                        isGridView: _isGridView,
                        onNoteSelect: widget.onNoteSelect,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

