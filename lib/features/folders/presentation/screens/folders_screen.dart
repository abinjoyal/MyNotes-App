import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynotes/features/folders/domain/entities/folder.dart';
import 'package:mynotes/features/notes/presentation/controllers/notes_controller.dart';
import '../../../../app/constants/app_colors.dart';
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

  void _confirmDeleteFolder(String folderName, FoldersController controller, NotesController notesController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $folderName?'),
        content: const Text('Are you sure you want to delete this folder? Your notes inside will NOT be deleted, but they will be removed from this folder.'),
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
                controller.addFolder(nameController.text, AppColors.primaryPurple);
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
    final folders = foldersController.folders;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF18181C) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.darkText;
   

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
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '📁 Folders',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightLavender,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${folders.length}',
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
                      const Text(
                        'Organize and browse your notes by project folders.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _showCreateFolderDialog(foldersController),
                    icon: Icon(Icons.add_rounded, size: 28, color: textColor),
                    tooltip: 'Create New Folder',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Folders Grid
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisExtent: 140,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    final count = notesController.getFolderNotesCount(
                      folder.name,
                    );

                    return FolderTile(
                      folder: folder,
                      count: count,
                      onTap: () {
                        setState(() {
                          _currentFolder = folder.name;
                        });
                      },
                      onAddNote: () => _createNoteInFolder(folder.name),
                      onDelete: () => _confirmDeleteFolder(folder.name, foldersController, notesController),
                    ).animate()
                     .fade(duration: 300.ms, delay: (index * 40).ms)
                     .scaleXY(begin: 0.95, duration: 300.ms, curve: Curves.easeOutBack);
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

  Widget _buildFolderDetailView(BuildContext context, String folderName) {
    final notesController = ref.watch(notesProvider);
    final foldersController = ref.watch(foldersProvider);
    final folderNotes = notesController.getNotesByFolder(folderName);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF18181C) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.darkText;
    final buttonBg = isDark ? const Color(0xFF232329) : const Color(0xFFF7F8FA);
    final borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFEAEAEE);

    final folderModel = foldersController.folders.firstWhere(
      (f) => f.name == folderName,
      orElse: () =>
          Folder(id: '0', name: folderName, color: const Color(0xFF635BFF)),
    );

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
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button & Folder Header Row
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentFolder = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: buttonBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: textColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'All Folders',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Row with Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.folder_rounded,
                        size: 28,
                        color: folderModel.color,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${folderModel.name} Notes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightLavender,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${folderNotes.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
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
                        label: Text('New Note in ${folderModel.name}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
      ),
    );
  }
}
