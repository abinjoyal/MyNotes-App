import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mynotes/app/constants/app_colors.dart';
import 'package:mynotes/app/theme/app_theme_colors.dart';
import 'package:mynotes/core/extensions/date_extensions.dart';
import 'package:mynotes/features/folders/presentation/controllers/folders_controller.dart';
import 'package:mynotes/features/notes/domain/entities/note.dart';
import 'package:mynotes/features/notes/presentation/controllers/notes_controller.dart';

class LockedNotesScreen extends StatefulWidget {
  final Function(Note)? onNoteSelect;

  const LockedNotesScreen({super.key, this.onNoteSelect});

  @override
  State<LockedNotesScreen> createState() => _LockedNotesScreenState();
}

class _LockedNotesScreenState extends State<LockedNotesScreen> {
  final NotesController _controller = NotesController.instance;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 16.0),
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    Material(
                      color: colors.isDark
                          ? const Color(0xFF1E1E2A)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: colors.textColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Locked Notes',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: colors.textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Passcode-protected private notes & items',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  _controller,
                  FoldersController.instance,
                ]),
                builder: (context, _) {
                  final lockedNotes = _controller.lockedNotes;

                  if (lockedNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colors.isDark
                                  ? const Color(0xFF1E1E2A)
                                  : const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              size: 56,
                              color: colors.secondaryTextColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Locked Notes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Notes marked as locked will safely appear here.',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 360,
                          mainAxisExtent: 190,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                    itemCount: lockedNotes.length,
                    itemBuilder: (context, index) {
                      final note = lockedNotes[index];
                      return _buildLockedNoteCard(context, note, colors, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedNoteCard(
    BuildContext context,
    Note note,
    AppThemeColors colors,
    int index,
  ) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: note.indicatorColor.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: note.indicatorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Protected Note' : note.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colors.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: AppColors.primaryPurple,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content.isEmpty ? 'Empty note content' : note.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.secondaryTextColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: colors.borderColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatRelativeTime(note.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.secondaryTextColor,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _controller.toggleNoteLock(note.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Note unlocked!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_open_rounded,
                            size: 14,
                            color: AppColors.primaryPurple,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Unlock',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fade(duration: 200.ms, delay: (index * 40).ms)
        .slideY(begin: 0.05);
  }
}
