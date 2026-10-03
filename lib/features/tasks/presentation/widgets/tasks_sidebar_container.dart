import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/controllers/notes_provider.dart';
import '../../domain/entities/task.dart';

class TasksSidebarContainer extends ConsumerWidget {
  final List<Note> checklistNotes;
  final Note? activeNote;
  final bool isWorkspaceHidden;
  final bool isGridView;
  final Function(String noteId) onSelectNote;
  final VoidCallback onCreateChecklist;
  final List<TaskItem> Function(String content) parseTasksFromContent;
  final IconData Function(String title) getCategoryIcon;

  const TasksSidebarContainer({
    super.key,
    required this.checklistNotes,
    required this.activeNote,
    required this.isWorkspaceHidden,
    required this.isGridView,
    required this.onSelectNote,
    required this.onCreateChecklist,
    required this.parseTasksFromContent,
    required this.getCategoryIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final isDark = colors.isDark;
    final cardBg = colors.cardBg;
    final textColor = colors.textColor;
    final subtextColor = colors.secondaryTextColor;
    final borderColor = colors.borderColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'My Checklists',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (isWorkspaceHidden) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightLavender,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Full View',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                icon: Icon(Icons.add_rounded, size: 20, color: textColor),
                onPressed: onCreateChecklist,
                tooltip: 'Add New Checklist',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: checklistNotes.isEmpty
                ? Center(
                    child: Text(
                      'No Checklists Created',
                      style: TextStyle(color: subtextColor, fontSize: 13),
                    ),
                  )
                : (isGridView
                      ? GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: isWorkspaceHidden
                                    ? 260
                                    : 250,
                                mainAxisExtent: 88,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: checklistNotes.length,
                          itemBuilder: (context, index) {
                            final note = checklistNotes[index];
                            final isSelected =
                                !isWorkspaceHidden && activeNote?.id == note.id;
                            final tasks = parseTasksFromContent(note.content);
                            final done = tasks
                                .where((t) => t.isCompleted)
                                .length;

                            return InkWell(
                              onTap: () => onSelectNote(note.id),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                            ? AppColors.primaryPurple
                                                  .withOpacity(0.2)
                                            : AppColors.lightLavender
                                                  .withOpacity(0.7))
                                      : (isDark
                                            ? const Color(0xFF1E1E26)
                                            : const Color(0xFFF9FAFC)),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryPurple
                                        : borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF262630)
                                            : const Color(0xFFF1F3F6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        getCategoryIcon(note.title),
                                        size: 20,
                                        color: isSelected
                                            ? AppColors.primaryPurple
                                            : subtextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            note.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isSelected
                                                  ? AppColors.primaryPurple
                                                  : textColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${tasks.length} tasks • $done completed',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: subtextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                      ),
                                      color: subtextColor.withOpacity(0.5),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        ref
                                            .read(notesProvider)
                                            .deleteNote(note.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: checklistNotes.length,
                          itemBuilder: (context, index) {
                            final note = checklistNotes[index];
                            final isSelected =
                                !isWorkspaceHidden && activeNote?.id == note.id;
                            final tasks = parseTasksFromContent(note.content);
                            final done = tasks
                                .where((t) => t.isCompleted)
                                .length;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.primaryPurple.withOpacity(
                                              0.2,
                                            )
                                          : AppColors.lightLavender.withOpacity(
                                              0.7,
                                            ))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : Colors.transparent,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF262630)
                                          : const Color(0xFFF1F3F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      getCategoryIcon(note.title),
                                      size: 18,
                                      color: isSelected
                                          ? AppColors.primaryPurple
                                          : subtextColor,
                                    ),
                                  ),
                                  title: Text(
                                    note.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSelected
                                          ? AppColors.primaryPurple
                                          : textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${tasks.length} tasks • $done completed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: subtextColor,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                    ),
                                    color: subtextColor.withOpacity(0.5),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      ref
                                          .read(notesProvider)
                                          .deleteNote(note.id);
                                    },
                                  ),
                                  onTap: () => onSelectNote(note.id),
                                ),
                              ),
                            );
                          },
                        )),
          ),
        ],
      ),
    );
  }
}
