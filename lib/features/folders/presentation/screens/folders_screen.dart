import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/features/folders/domain/entities/folder.dart';
import 'package:notes/features/notes/presentation/controllers/notes_controller.dart';
import 'package:notes/features/pin/presentation/screens/passcode_lock_screen.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/controllers/notes_provider.dart';
import '../../../notes/presentation/widgets/note_list.dart';
import '../../../settings/controllers/settings_controller.dart';
import '../controllers/folders_controller.dart';
import '../widgets/folder_tile.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FoldersScreen extends ConsumerStatefulWidget {
  final String? selectedFolderName;
  final Function(Note)? onNoteSelect;

  const FoldersScreen({super.key, this.selectedFolderName, this.onNoteSelect});

  @override
  ConsumerState<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends ConsumerState<FoldersScreen> {
  late String? _currentFolder;
  late bool _isGridView;
  String _searchQuery = '';
  String _selectedSort = 'Recently Updated';

  @override
  void initState() {
    super.initState();
    _currentFolder = widget.selectedFolderName;
    _isGridView = SettingsController.instance.isGridView;
  }

  @override
  void didUpdateWidget(covariant FoldersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFolderName != widget.selectedFolderName) {
      setState(() {
        _currentFolder = widget.selectedFolderName;
      });
    }
  }

  void _createNoteInFolder(String folderName) {
    if (widget.onNoteSelect != null) {
      final newNote = Note(
        id: '',
        title: '',
        content: '',
        indicatorColor: const Color(0xFF635BFF),
        tags: ['#${folderName.toLowerCase()}'],
        updatedAt: 'Draft',
        folderName: folderName,
      );
      widget.onNoteSelect!(newNote);
    }
  }

  void _confirmDeleteFolder(
    String folderName,
    FoldersController controller,
    NotesController notesController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $folderName?'),
        content: const Text(
          'Are you sure you want to delete this folder? Your notes inside will NOT be deleted, but they will be removed from this folder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteFolderToTrash(folderName);
              notesController.loadFromDatabase();
              Navigator.pop(context);
              if (_currentFolder == folderName) {
                setState(() => _currentFolder = null);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog(FoldersController controller) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Folder'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Folder Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.addFolder(
                  nameController.text,
                  AppColors.primaryPurple,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentFolder != null && _currentFolder!.isNotEmpty) {
      return _buildFolderDetailView(context, _currentFolder!);
    }
    return _buildFolderGridOverview(context);
  }

  Widget _buildFolderGridOverview(BuildContext context) {
    final notesController = ref.watch(notesProvider);
    final foldersController = ref.watch(foldersProvider);
    final allFolders = foldersController.folders;
    final colors = context.appColors;
    final textColor = colors.textColor;
    final containerBg = colors.cardBg;
    final borderColor = colors.borderColor;
    final hintColor = colors.secondaryTextColor;

    // Filter folders by search query
    final filteredFolders = allFolders.where((folder) {
      return folder.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort folders
    if (_selectedSort == 'Name (A-Z)') {
      filteredFolders.sort((a, b) => a.name.compareTo(b.name));
    } else if (_selectedSort == 'Note Count') {
      filteredFolders.sort((a, b) {
        final countA = notesController.getFolderNotesCount(a.name);
        final countB = notesController.getFolderNotesCount(b.name);
        return countB.compareTo(countA);
      });
    }

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row (Title, Subtitle, + New Folder Button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Folders',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Organize and browse your notes by project folders.',
                        style: TextStyle(fontSize: 13, color: hintColor),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateFolderDialog(foldersController),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      'New Folder',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Search & Controls Bar
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: containerBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search folders...',
                          hintStyle: TextStyle(color: hintColor, fontSize: 14),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: hintColor,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Layout View Switcher (Grid / List)
                  Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: containerBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isGridView = true),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _isGridView
                                  ? AppColors.primaryPurple
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              Icons.grid_view_rounded,
                              size: 18,
                              color: _isGridView ? Colors.white : hintColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: () => setState(() => _isGridView = false),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: !_isGridView
                                  ? AppColors.primaryPurple
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              Icons.format_list_bulleted_rounded,
                              size: 18,
                              color: !_isGridView ? Colors.white : hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Sort Dropdown
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: containerBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: hintColor,
                          size: 18,
                        ),
                        dropdownColor: colors.dropdownBg,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedSort = val);
                          }
                        },
                        items: ['Recently Updated', 'Name (A-Z)', 'Note Count']
                            .map((sortOption) {
                              return DropdownMenuItem<String>(
                                value: sortOption,
                                child: Text('Sort: $sortOption'),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Folders Grid / List
              Expanded(
                child: filteredFolders.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No folders match "$_searchQuery"'
                              : 'No folders found',
                          style: TextStyle(color: hintColor, fontSize: 15),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 4;
                          if (constraints.maxWidth < 600) {
                            crossAxisCount = 1;
                          } else if (constraints.maxWidth < 900) {
                            crossAxisCount = 2;
                          } else if (constraints.maxWidth < 1200) {
                            crossAxisCount = 3;
                          } else {
                            crossAxisCount = 4;
                          }

                          if (!_isGridView) {
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredFolders.length,
                              itemBuilder: (context, index) {
                                final folder = filteredFolders[index];
                                final folderNotes = notesController
                                    .getNotesByFolder(folder.name);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  child: FolderTile(
                                    folder: folder,
                                    count: folderNotes.length,
                                    previewNotes: folderNotes,
                                    onNoteSelect: widget.onNoteSelect,
                                    onToggleLock: () => _handleLockToggle(
                                      folder,
                                      foldersController,
                                    ),
                                    onTap: () => _openFolderDetail(folder),
                                    onAddNote: () =>
                                        _createNoteInFolder(folder.name),
                                    onDelete: () => _confirmDeleteFolder(
                                      folder.name,
                                      foldersController,
                                      notesController,
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          return GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisExtent: 235,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: filteredFolders.length,
                            itemBuilder: (context, index) {
                              final folder = filteredFolders[index];
                              final folderNotes = notesController
                                  .getNotesByFolder(folder.name);

                              return FolderTile(
                                    folder: folder,
                                    count: folderNotes.length,
                                    previewNotes: folderNotes,
                                    onNoteSelect: widget.onNoteSelect,
                                    onToggleLock: () => _handleLockToggle(
                                      folder,
                                      foldersController,
                                    ),
                                    onTap: () => _openFolderDetail(folder),
                                    onAddNote: () =>
                                        _createNoteInFolder(folder.name),
                                    onDelete: () => _confirmDeleteFolder(
                                      folder.name,
                                      foldersController,
                                      notesController,
                                    ),
                                  )
                                  .animate()
                                  .fade(
                                    duration: 300.ms,
                                    delay: (index * 40).ms,
                                  )
                                  .scaleXY(
                                    begin: 0.95,
                                    duration: 300.ms,
                                    curve: Curves.easeOutBack,
                                  );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLockToggle(
    Folder folder,
    FoldersController foldersController,
  ) async {
    if (folder.isLocked) {
      final success = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PasscodeLockScreen(isSetupMode: false),
        ),
      );
      if (success == true) {
        foldersController.toggleFolderLock(folder.name, false);
      }
    } else {
      if (SettingsController.instance.hasPinCode) {
        foldersController.toggleFolderLock(folder.name, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please set up a Passcode in Settings first.'),
          ),
        );
      }
    }
  }

  void _openFolderDetail(Folder folder) async {
    if (folder.isLocked) {
      final success = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PasscodeLockScreen(isSetupMode: false),
        ),
      );
      if (success != true) return;
    }
    setState(() {
      _currentFolder = folder.name;
    });
  }

  Widget _buildFolderDetailView(BuildContext context, String folderName) {
    final notesController = ref.watch(notesProvider);
    final foldersController = ref.watch(foldersProvider);
    final folderNotes = notesController.getNotesByFolder(folderName);

    final colors = context.appColors;
    final textColor = colors.textColor;
    final buttonBg = colors.cardBg;
    final borderColor = colors.borderColor;

    final folderModel = foldersController.folders.firstWhere(
      (f) => f.name == folderName,
      orElse: () =>
          Folder(id: '0', name: folderName, color: AppColors.primaryPurple),
    );

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Navigation Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentFolder = null;
                          });
                        },
                        icon: Icon(Icons.arrow_back_rounded, color: textColor),
                        tooltip: 'Back to Folders',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        folderModel.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: buttonBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _isGridView = false),
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
                                      : AppColors.lightText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => setState(() => _isGridView = true),
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
                                      : AppColors.lightText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _createNoteInFolder(folderName),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('New Note'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Folder Notes List / Empty State
              Expanded(
                child: NoteList(
                  notes: folderNotes,
                  isGridView: _isGridView,
                  activeRoute: 'folder',
                  onNoteSelect: widget.onNoteSelect,
                  onActionTap: () => _createNoteInFolder(folderName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
