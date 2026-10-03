import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../notes/domain/entities/note.dart';
import '../../domain/entities/task.dart';

class TasksDetailWorkspace extends StatelessWidget {
  final Note? activeNote;
  final List<TaskItem> activeTasks;
  final TextEditingController newTaskController;
  final VoidCallback onCloseWorkspace;
  final Function(Note note)? onNoteEditSelect;
  final Function(Note note, TaskItem task) onToggleTaskCompletion;
  final Function(Note note, TaskItem task) onDeleteTaskItem;
  final Function(Note note) onAddNewTask;
  final IconData Function(String title) getCategoryIcon;
  final Color Function(String? tag) getTagColor;

  const TasksDetailWorkspace({
    super.key,
    required this.activeNote,
    required this.activeTasks,
    required this.newTaskController,
    required this.onCloseWorkspace,
    required this.onNoteEditSelect,
    required this.onToggleTaskCompletion,
    required this.onDeleteTaskItem,
    required this.onAddNewTask,
    required this.getCategoryIcon,
    required this.getTagColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = colors.isDark;
    final cardBg = colors.cardBg;
    final textColor = colors.textColor;
    final subtextColor = colors.secondaryTextColor;
    final borderColor = colors.borderColor;
    final inputBg = isDark ? const Color(0xFF262630) : const Color(0xFFF7F8FA);

    if (activeNote == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'Select or create a checklist to get started',
            style: TextStyle(color: subtextColor, fontSize: 14),
          ),
        ),
      );
    }

    final note = activeNote!;
    final completedCount = activeTasks.where((t) => t.isCompleted).length;
    final totalCount = activeTasks.length;
    final progressVal = totalCount > 0 ? completedCount / totalCount : 0.0;
    final progressPct = (progressVal * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getCategoryIcon(note.title),
                      size: 26,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Stay productive and get things done.',
                        style: TextStyle(fontSize: 13, color: subtextColor),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      if (onNoteEditSelect != null) {
                        onNoteEditSelect!(note);
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Close Workspace Panel',
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: subtextColor,
                    onPressed: onCloseWorkspace,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Indicator Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalCount tasks • $completedCount completed',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
              Text(
                '$progressPct%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 8,
              backgroundColor: isDark
                  ? const Color(0xFF2C2C35)
                  : const Color(0xFFEEECFF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Add Task Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: newTaskController,
                    onSubmitted: (_) => onAddNewTask(note),
                    style: TextStyle(fontSize: 14, color: textColor),
                    decoration: const InputDecoration(
                      hintText: 'O  Add a new task...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8C98A9),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => onAddNewTask(note),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Task Items List
          Expanded(
            child: activeTasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks added yet. Type above to add your first task!',
                      style: TextStyle(color: subtextColor, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: activeTasks.length,
                    itemBuilder: (context, index) {
                      final task = activeTasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E26)
                              : const Color(0xFFF9FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => onToggleTaskCompletion(note, task),
                              child: Icon(
                                task.isCompleted
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: task.isCompleted
                                    ? AppColors.primaryPurple
                                    : const Color(0xFF8C98A9),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                task.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: task.isCompleted
                                      ? subtextColor
                                      : textColor,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                            if (task.tag != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: getTagColor(
                                    task.tag,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  task.tag!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: getTagColor(task.tag),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              task.time,
                              style: TextStyle(
                                fontSize: 12,
                                color: subtextColor,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Color(0xFF8C98A9),
                              ),
                              onPressed: () => onDeleteTaskItem(note, task),
                              tooltip: 'Delete task',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
