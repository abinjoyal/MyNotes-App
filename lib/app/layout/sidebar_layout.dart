import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_sizes.dart';
import '../../features/notes/presentation/controllers/notes_provider.dart';
import '../../features/folders/presentation/controllers/folders_controller.dart';

class SidebarLayout extends ConsumerStatefulWidget {
  final String activeRoute;
  final Function(String route)? onNavigate;

  const SidebarLayout({
    super.key,
    this.activeRoute = 'all_notes',
    this.onNavigate,
  });

  @override
  ConsumerState<SidebarLayout> createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends ConsumerState<SidebarLayout> {
  late String _selectedRoute;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _selectedRoute = widget.activeRoute;
  }

  @override
  Widget build(BuildContext context) {
    final _controller = ref.watch(notesProvider);
    final _foldersController = ref.watch(foldersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBg = isDark
        ? const Color(0xFF18181C)
        : const Color(0xFFF9FAFC);
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFEAEAEE);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isCollapsed ? AppSizes.sidebarCollapsedWidth : AppSizes.sidebarWidth,
      height: double.infinity,
      color: sidebarBg,
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: _isCollapsed ? AppSizes.sidebarCollapsedWidth : AppSizes.sidebarWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _isCollapsed ? 8.0 : 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          // 1. Window Control Dots (macOS Style)
          if (!_isCollapsed)
            const Row(
              children: [
                _WindowDot(color: Color(0xFFFF5F56)),
                SizedBox(width: 6),
                _WindowDot(color: Color(0xFFFFBD2E)),
                SizedBox(width: 6),
                _WindowDot(color: Color(0xFF27C93F)),
              ],
            ),
          
          if (!_isCollapsed) const SizedBox(height: 16),

          // 2. App Logo & Brand Name & Menu Icon
          Row(
            mainAxisAlignment: _isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (!_isCollapsed) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'MyNotes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
              IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: textColor,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. "+ New Note" Primary Action Button with Template Dropdown
          if (_isCollapsed)
            Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _select('new_note'),
                ),
              ),
            )
          else
            Container(
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _select('new_note'),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'New Note',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (templateType) {
                    _select('new_note:$templateType');
                  },
                  tooltip: 'Choose Template',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 18,
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'blank',
                      child: Row(
                        children: [
                          Icon(
                            Icons.note_add_outlined,
                            size: 18,
                            color: AppColors.primaryPurple,
                          ),
                          SizedBox(width: 8),
                          Text('Blank Note'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'checklist',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_box_outlined,
                            size: 18,
                            color: Color(0xFF00C853),
                          ),
                          SizedBox(width: 8),
                          Text('Task Checklist'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'journal',
                      child: Row(
                        children: [
                          Icon(
                            Icons.today_outlined,
                            size: 18,
                            color: Color(0xFFFFB020),
                          ),
                          SizedBox(width: 8),
                          Text('Daily Journal'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'meeting',
                      child: Row(
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 18,
                            color: Color(0xFF4C6FFF),
                          ),
                          SizedBox(width: 8),
                          Text('Meeting Notes'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3.5 Quick Search Input Bar
          // Container(
          //   height: 36,
          //   decoration: BoxDecoration(
          //     color: cardBg,
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(color: borderColor),
          //   ),
          //   child: TextField(
          //     style: TextStyle(fontSize: 13, color: textColor),
          //     decoration: const InputDecoration(
          //       hintText: 'Search notes... (Ctrl+K)',
          //       hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          //       prefixIcon: Icon(Icons.search_rounded, size: 16, color: Color(0xFF9CA3AF)),
          //       border: InputBorder.none,
          //       contentPadding: EdgeInsets.symmetric(vertical: 8),
          //       isDense: true,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 16),

          // Scrollable Sidebar Navigation List
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Navigation Items
                  _NavItem(
                    icon: AppIcons.notes,
                    title: 'All Notes',
                    badgeCount: _controller.regularNotesCount,
                    isSelected: _selectedRoute == 'all_notes',
                    isCollapsed: _isCollapsed,
                    onTap: () => _select('all_notes'),
                  ),
                  _NavItem(
                    icon: AppIcons.pin,
                    title: 'Pinned',
                    badgeCount: _controller.pinnedNotesCount,
                    isSelected: _selectedRoute == 'pinned',
                    isCollapsed: _isCollapsed,
                    onTap: () => _select('pinned'),
                  ),
                  _NavItem(
                    icon: AppIcons.checkbox,
                    title: 'Tasks',
                    badgeCount: _controller.taskChecklistNotesCount,
                    isSelected: _selectedRoute == 'tasks',
                    isCollapsed: _isCollapsed,
                    onTap: () => _select('tasks'),
                  ),
                  const SizedBox(height: 20),

                  // FOLDERS Section
                  if (!_isCollapsed) ...[
                    _SectionHeader(
                      title: 'FOLDERS',
                      onAddTap: () => _showCreateFolderDialog(context),
                    ),
                    const SizedBox(height: 6),
                    if (_foldersController.folders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'No folders created yet',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8C98A9),
                          ),
                        ),
                      )
                    else
                    ..._foldersController.folders.map(
                      (folder) => _FolderItem(
                        title: folder.name,
                        count: _controller.getFolderNotesCount(folder.name),
                        folderColor: folder.color,
                        isCollapsed: _isCollapsed,
                        onTap: () => _select('folder:${folder.name}'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // RECENT NOTES Section
                    const Text(
                      'RECENT NOTES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8C98A9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_controller.regularNotes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'No recent notes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8C98A9),
                          ),
                        ),
                      )
                    else
                      ..._controller.regularNotes
                          .take(5)
                          .map(
                            (note) => _RecentNoteItem(
                              color: note.indicatorColor,
                              title: note.title,
                              time: note.updatedAt,
                              onTap: () => _select('open_note:${note.id}'),
                            ),
                          ),
                    const SizedBox(height: 20),
                  ] else ...[
                    // Just icons for folders when collapsed
                    ..._foldersController.folders.map(
                      (folder) => _FolderItem(
                        title: folder.name,
                        count: _controller.getFolderNotesCount(folder.name),
                        folderColor: folder.color,
                        isCollapsed: _isCollapsed,
                        onTap: () => _select('folder:${folder.name}'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Trash
                  _NavItem(
                    icon: AppIcons.trash,
                    title: 'Trash',
                    badgeCount: _controller.trashedNotesCount,
                    isSelected: _selectedRoute == 'trash',
                    isCollapsed: _isCollapsed,
                    onTap: () => _select('trash'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Settings Card
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _select('settings'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _isCollapsed ? 0 : 14,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: _isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Icon(Icons.settings_outlined, color: textColor, size: 20),
                      if (!_isCollapsed) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
            ),
          ),
        ),
      ),
    );
  }

  void _select(String route) {
    setState(() => _selectedRoute = route);
    if (widget.onNavigate != null) {
      widget.onNavigate!(route);
    }
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    Color selectedColor = const Color(0xFF635BFF);
    final colors = const [
      Color(0xFF635BFF),
      Color(0xFFA259FF),
      Color(0xFF02569B),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFEC4899),
      Color(0xFFFF9800),
      Color(0xFF6B7280),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Create New Folder',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Folder name (e.g. Design System)',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFEAEAEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFEAEAEE)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Folder Color:',
                style: TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: colors.map((c) {
                  final isSelected = selectedColor == c;
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedColor = c;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppColors.darkText, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref.read(foldersProvider).addFolder(controller.text.trim(), selectedColor);
                  Navigator.of(ctx).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Create Folder'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widgets
class _WindowDot extends StatelessWidget {
  final Color color;
  const _WindowDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int badgeCount;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.badgeCount,
    required this.isSelected,
    this.isCollapsed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark
        ? const Color(0xFFE0E0E0)
        : AppColors.darkText;
    final selectedBg = isDark
        ? AppColors.primaryPurple.withOpacity(0.25)
        : AppColors.lightLavender;
    final itemColor = isSelected ? AppColors.primaryPurple : unselectedColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: isCollapsed
            ? Tooltip(
                message: title,
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Icon(icon, color: itemColor, size: 20),
                  ),
                ),
              )
            : ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                horizontalTitleGap: 8,
                onTap: onTap,
                leading: Icon(icon, color: itemColor, size: 18),
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: itemColor,
                  ),
                ),
                trailing: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: itemColor,
                  ),
                ),
              ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAddTap;

  const _SectionHeader({required this.title, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8C98A9),
            letterSpacing: 0.5,
          ),
        ),
        InkWell(
          onTap: onAddTap,
          borderRadius: BorderRadius.circular(4),
          child: const Icon(Icons.add, size: 16, color: Color(0xFF8C98A9)),
        ),
      ],
    );
  }
}

class _FolderItem extends StatelessWidget {
  final String title;
  final int count;
  final Color folderColor;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _FolderItem({
    required this.title,
    required this.count,
    this.folderColor = AppColors.primaryPurple,
    this.isCollapsed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppColors.darkText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: isCollapsed
          ? Tooltip(
              message: title,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Icon(Icons.folder_rounded, color: folderColor, size: 20),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.folder_rounded, color: folderColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _RecentNoteItem extends StatelessWidget {
  final Color color;
  final String title;
  final String time;
  final VoidCallback onTap;

  const _RecentNoteItem({
    required this.color,
    required this.title,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE0E0E0) : AppColors.darkText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8C98A9)),
          ),
        ],
      ),
      ),
    );
  }
}
