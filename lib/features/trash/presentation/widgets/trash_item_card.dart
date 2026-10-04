import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../notes/domain/entities/note.dart';

class TrashItemCard extends StatefulWidget {
  final Note note;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const TrashItemCard({
    super.key,
    required this.note,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  State<TrashItemCard> createState() => _TrashItemCardState();
}

class _TrashItemCardState extends State<TrashItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hoverBg = colors.isDark
        ? const Color(0xFF22222E)
        : const Color(0xFFF8F9FA);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? hoverBg : colors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.note.indicatorColor.withOpacity(0.6)
                : colors.borderColor,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.note.indicatorColor.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Dot Indicator
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.note.indicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.note.title.isEmpty
                        ? 'Untitled Note'
                        : widget.note.title,
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Content Snippet
            Expanded(
              child: Text(
                widget.note.content.isEmpty
                    ? 'No content'
                    : widget.note.content,
                style: TextStyle(
                  color: colors.secondaryTextColor,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 10),
            Divider(height: 1, color: colors.borderColor),
            const SizedBox(height: 10),

            // Footer: Time & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: colors.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatRelativeTime(widget.note.updatedAt),
                      style: TextStyle(
                        color: colors.secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Restore Button
                    Tooltip(
                      message: 'Restore Note',
                      child: InkWell(
                        onTap: widget.onRestore,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.restore_rounded,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Restore',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Delete Button
                    Tooltip(
                      message: 'Delete Permanently',
                      child: InkWell(
                        onTap: widget.onDelete,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
