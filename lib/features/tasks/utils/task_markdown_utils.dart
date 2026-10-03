import 'package:flutter/material.dart';
import 'package:mynotes/features/tasks/domain/entities/task.dart';
import '../../../../app/constants/app_colors.dart';

class TaskMarkdownUtils {
  TaskMarkdownUtils._();

  static List<TaskItem> parseTasksFromContent(String content) {
    final lines = content.split('\n');
    final List<TaskItem> tasks = [];
    int idx = 0;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- [ ] ') ||
          trimmed.startsWith('- [x] ') ||
          trimmed.startsWith('- [X] ')) {
        final isDone =
            trimmed.startsWith('- [x] ') || trimmed.startsWith('- [X] ');
        String rawText = trimmed.substring(6).trim();

        String? tag;
        final tagMatch = RegExp(r'#(\w+)').firstMatch(rawText);
        if (tagMatch != null) {
          tag = tagMatch.group(1);
          rawText = rawText.replaceAll(RegExp(r'#\w+'), '').trim();
        }

        tasks.add(
          TaskItem(
            index: idx,
            text: rawText.isEmpty ? 'Untitled Task' : rawText,
            isCompleted: isDone,
            tag: tag,
            time: 'Today',
          ),
        );
      }
      idx++;
    }

    return tasks;
  }

  static String toggleTaskInContent(
    String content,
    int taskIndex,
    bool currentIsCompleted,
  ) {
    final lines = content.split('\n');
    int matchIdx = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('- [ ] ') ||
          line.startsWith('- [x] ') ||
          line.startsWith('- [X] ')) {
        if (matchIdx == taskIndex) {
          final prefix = currentIsCompleted ? '- [ ] ' : '- [x] ';
          final contentPart = line.substring(6);
          lines[i] = '$prefix$contentPart';
          break;
        }
        matchIdx++;
      }
    }

    return lines.join('\n');
  }

  static String addNewTaskToContent(String content, String newTaskText) {
    final trimmedText = newTaskText.trim();
    if (trimmedText.isEmpty) return content;

    if (content.isEmpty) {
      return '- [ ] $trimmedText';
    } else {
      return '$content\n- [ ] $trimmedText';
    }
  }

  static String deleteTaskFromContent(String content, int taskIndex) {
    final lines = content.split('\n');
    int matchIdx = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('- [ ] ') ||
          line.startsWith('- [x] ') ||
          line.startsWith('- [X] ')) {
        if (matchIdx == taskIndex) {
          lines.removeAt(i);
          break;
        }
        matchIdx++;
      }
    }

    return lines.join('\n');
  }

  static IconData getCategoryIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('daily') ||
        lower.contains('morning') ||
        lower.contains('sun')) {
      return Icons.wb_sunny_outlined;
    } else if (lower.contains('work') ||
        lower.contains('office') ||
        lower.contains('job')) {
      return Icons.work_outline_rounded;
    } else if (lower.contains('study') ||
        lower.contains('learn') ||
        lower.contains('school')) {
      return Icons.school_outlined;
    } else if (lower.contains('home') ||
        lower.contains('house') ||
        lower.contains('chore')) {
      return Icons.home_outlined;
    } else if (lower.contains('fit') ||
        lower.contains('gym') ||
        lower.contains('workout')) {
      return Icons.fitness_center_rounded;
    } else if (lower.contains('shop') ||
        lower.contains('store') ||
        lower.contains('buy')) {
      return Icons.shopping_cart_outlined;
    }
    return Icons.check_box_outlined;
  }

  static Color getTagColor(String? tag) {
    if (tag == null) return AppColors.primaryPurple;
    final lower = tag.toLowerCase();
    if (lower == 'health') return const Color(0xFF00C853);
    if (lower == 'learning') return const Color(0xFF635BFF);
    if (lower == 'work') return const Color(0xFF4C6FFF);
    if (lower == 'personal') return const Color(0xFFFF4081);
    return AppColors.primaryPurple;
  }
}
