import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onPinToggle;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onPinToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Indicator Row with 3-dot Options Menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Category Color Indicator
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: note.indicatorColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Note Title
                        Expanded(
                          child: Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Pinned Badge Indicator
                        if (note.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.push_pin_rounded,
                              size: 16,
                              color: AppColors.primaryPurple,
                            ),
                          ),

                        // 3-Dot Options Menu (Pin, Edit, Delete)
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              size: 18,
                              color: Color(0xFF8C98A9),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onSelected: (value) {
                              if (value == 'pin') {
                                onPinToggle?.call();
                              } else if (value == 'edit') {
                                onTap?.call();
                              } else if (value == 'delete') {
                                onDelete?.call();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'pin',
                                child: Row(
                                  children: [
                                    Icon(
                                      note.isPinned
                                          ? Icons.push_pin_outlined
                                          : Icons.push_pin_rounded,
                                      size: 16,
                                      color: AppColors.primaryPurple,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      note.isPinned ? 'Unpin Note' : 'Pin Note',
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: AppColors.darkText,
                                    ),
                                    SizedBox(width: 10),
                                    Text('Edit Note'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: Color(0xFFFF4B4B),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Delete Note',
                                      style: TextStyle(
                                        color: Color(0xFFFF4B4B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Note Content Preview Snippet
                    Text(
                      note.content,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF6C757D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tags & Time Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tag Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: note.tags
                          .map((tag) => _TagChip(tag: tag))
                          .toList(),
                    ),
                    Text(
                      note.updatedAt,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF98A2B3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.lightLavender;
    Color text = AppColors.primaryPurple;

    if (tag.toLowerCase() == '#project') {
      bg = const Color(0xFFE8F8EE);
      text = const Color(0xFF00C853);
    } else if (tag.toLowerCase() == '#daily') {
      bg = const Color(0xFFFFF4E5);
      text = const Color(0xFFFF9800);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag.startsWith('#') ? tag : '#$tag',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
