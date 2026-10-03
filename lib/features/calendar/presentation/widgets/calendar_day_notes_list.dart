import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/widgets/note_list.dart';

class CalendarDayNotesList extends StatelessWidget {
  final DateTime selectedDate;
  final List<Note> selectedNotes;
  final bool isGridView;
  final Function(Note)? onNoteSelect;
  final VoidCallback? onAddNoteForDate;

  const CalendarDayNotesList({
    super.key,
    required this.selectedDate,
    required this.selectedNotes,
    required this.isGridView,
    this.onNoteSelect,
    this.onAddNoteForDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final subtextColor = isDark
        ? const Color(0xFF8C98A9)
        : const Color(0xFF6C757D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notes for ${DateFormat.yMMMd().format(selectedDate)}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (onAddNoteForDate != null)
              TextButton.icon(
                onPressed: onAddNoteForDate,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: AppColors.primaryPurple,
                ),
                label: const Text(
                  'Add Note',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: selectedNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 40,
                        color: subtextColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No notes created on this date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : NoteList(
                  notes: selectedNotes,
                  isGridView: isGridView,
                  activeRoute: 'all_notes',
                  onNoteSelect: onNoteSelect,
                ),
        ),
      ],
    );
  }
}
