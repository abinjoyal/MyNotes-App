import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynotes/features/folders/domain/entities/folder.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/controllers/notes_provider.dart';
import '../../../notes/presentation/widgets/note_list.dart';
import '../controllers/folders_controller.dart';

class FoldersScreen extends ConsumerStatefulWidget {
  final String? selectedFolderName;
  final Function(Note)? onNoteSelect;

  const FoldersScreen({
    super.key,
    this.selectedFolderName,
    this.onNoteSelect,
  });

  @override
  ConsumerState<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends ConsumerState<FoldersScreen> {
  late String? _currentFolder;

  @override
  void initState() {
    super.initState();
    _currentFolder = widget.selectedFolderName;
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

  @override
  Widget build(BuildContext context) {
    if (_currentFolder != null && _currentFolder!.isNotEmpty) {
      return _buildFolderDetailView(context, _currentFolder!);
    }
    return _buildFolderGridOverview(context);
  }

  Widget _buildFolderGridOverview(BuildContext context) {
    final _notesController = ref.watch(notesProvider);
    final _foldersController = ref.watch(foldersProvider);
    final folders = _foldersController.folders;

    return Scaffold(
      backgroundColor: Colors.white,
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
                          const Text(
                            '📁 Folders',
                            style: TextStyle(
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
                    final count = _notesController.getFolderNotesCount(folder.name);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentFolder = folder.name;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEAEAEE)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: folder.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.folder_rounded,
                                    color: folder.color,
                                    size: 22,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Add note to ${folder.name}',
                                  icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 20,
                                    color: AppColors.primaryPurple,
                                  ),
                                  onPressed: () => _createNoteInFolder(folder.name),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  folder.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$count ${count == 1 ? 'note' : 'notes'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8C98A9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildFolderDetailView(BuildContext context, String folderName) {
    final _notesController = ref.watch(notesProvider);
    final _foldersController = ref.watch(foldersProvider);
    final folderNotes = _notesController.getNotesByFolder(folderName);
    
    final folderModel = _foldersController.folders.firstWhere(
      (f) => f.name == folderName,
      orElse: () => Folder(
        id: '0',
        name: folderName,
        color: const Color(0xFF635BFF),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEAEAEE)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.darkText),
                          SizedBox(width: 4),
                          Text(
                            'All Folders',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
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
                      Icon(Icons.folder_rounded, size: 28, color: folderModel.color),
                      const SizedBox(width: 10),
                      Text(
                        '${folderModel.name} Notes',
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
                  ElevatedButton.icon(
                    onPressed: () => _createNoteInFolder(folderName),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text('New Note in ${folderModel.name}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Folder Notes List / Empty State
              Expanded(
                child: NoteList(
                  notes: folderNotes,
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
