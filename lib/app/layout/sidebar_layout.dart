import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_sizes.dart';

class SidebarLayout extends StatefulWidget {
  final String activeRoute;
  final Function(String route)? onNavigate;

  const SidebarLayout({
    super.key,
    this.activeRoute = 'all_notes',
    this.onNavigate,
  });

  @override
  State<SidebarLayout> createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends State<SidebarLayout> {
  late String _selectedRoute;

  @override
  void initState() {
    super.initState();
    _selectedRoute = widget.activeRoute;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      height: double.infinity,
      color: const Color(0xFFF9FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Window Control Dots (macOS Style)
          const Row(
            children: [
              _WindowDot(color: Color(0xFFFF5F56)),
              SizedBox(width: 6),
              _WindowDot(color: Color(0xFFFFBD2E)),
              SizedBox(width: 6),
              _WindowDot(color: Color(0xFF27C93F)),
            ],
          ),
          const SizedBox(height: 16),

          // 2. App Logo & Brand Name
          Row(
            children: [
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
              const Text(
                'MyNotes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. "+ New Note" Primary Action Button
          Container(
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                      Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                    badgeCount: 128,
                    isSelected: _selectedRoute == 'all_notes',
                    onTap: () => _select('all_notes'),
                  ),
                  _NavItem(
                    icon: AppIcons.pin,
                    title: 'Pinned',
                    badgeCount: 7,
                    isSelected: _selectedRoute == 'pinned',
                    onTap: () => _select('pinned'),
                  ),
                  _NavItem(
                    icon: AppIcons.checkbox,
                    title: 'Tasks',
                    badgeCount: 24,
                    isSelected: _selectedRoute == 'tasks',
                    onTap: () => _select('tasks'),
                  ),
                  const SizedBox(height: 20),

                  // FOLDERS Section
                  _SectionHeader(
                    title: 'FOLDERS',
                    onAddTap: () {},
                  ),
                  const SizedBox(height: 6),
                  _FolderItem(title: 'Figma', count: 14, onTap: () {}),
                  _FolderItem(title: 'Flutter', count: 22, onTap: () {}),
                  _FolderItem(title: 'Projects', count: 16, onTap: () {}),
                  _FolderItem(title: 'Learning', count: 31, onTap: () {}),
                  _FolderItem(title: 'Personal', count: 9, onTap: () {}),
                  _FolderItem(title: 'Ideas', count: 12, onTap: () {}),
                  _FolderItem(title: 'Archive', count: 4, onTap: () {}),
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
                  const _RecentNoteItem(
                    color: Color(0xFF635BFF),
                    title: 'Figma Typography Guide',
                    time: '2m ago',
                  ),
                  const _RecentNoteItem(
                    color: Color(0xFF4C6FFF),
                    title: 'Flutter Workout Scree...',
                    time: '1h ago',
                  ),
                  const _RecentNoteItem(
                    color: Color(0xFFFF4B4B),
                    title: 'AI Food Scanner Project',
                    time: 'Yesterday',
                  ),
                  const _RecentNoteItem(
                    color: Color(0xFFFFB020),
                    title: 'Daily Note - Sep 3',
                    time: 'Yesterday',
                  ),
                  const _RecentNoteItem(
                    color: Color(0xFF00C853),
                    title: 'Design System Checklist',
                    time: 'Sep 2',
                  ),
                  const SizedBox(height: 20),

                  // Trash
                  _NavItem(
                    icon: AppIcons.trash,
                    title: 'Trash',
                    badgeCount: 8,
                    isSelected: _selectedRoute == 'trash',
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAEAEE)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _select('settings'),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, color: AppColors.darkText, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFF8C98A9), size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _select(String route) {
    setState(() => _selectedRoute = route);
    if (widget.onNavigate != null) {
      widget.onNavigate!(route);
    }
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
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.badgeCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightLavender : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        horizontalTitleGap: 8,
        onTap: onTap,
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primaryPurple : AppColors.darkText,
          size: 18,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primaryPurple : AppColors.darkText,
          ),
        ),
        trailing: Text(
          '$badgeCount',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primaryPurple : AppColors.darkText,
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
  final VoidCallback onTap;

  const _FolderItem({
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.folder_outlined, color: AppColors.primaryPurple, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
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

  const _RecentNoteItem({
    required this.color,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8C98A9),
            ),
          ),
        ],
      ),
    );
  }
}
