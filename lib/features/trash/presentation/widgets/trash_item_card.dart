import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../domain/entities/trash_item.dart';

class TrashItemCard extends StatefulWidget {
  final TrashItem item;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const TrashItemCard({
    super.key,
    required this.item,
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
        ? const Color(0xFF25252D)
        : const Color(0xFFF5F5F9);

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
                ? widget.item.note.indicatorColor.withOpacity(0.5)
                : colors.borderColor,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.item.note.indicatorColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.item.note.indicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.note.title,
                    style: TextStyle(
                      color: colors.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                widget.item.note.content,
                style: TextStyle(
                  color: colors.secondaryTextColor,
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Deleted: ${widget.item.deletedAt}',
                    style: TextStyle(
                      color: colors.secondaryTextColor,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Tooltip(
                      message: 'Restore Note',
                      child: IconButton(
                        icon: const Icon(
                          Icons.restore,
                          color: Colors.green,
                          size: 20,
                        ),
                        onPressed: widget.onRestore,
                        splashRadius: 20,
                      ),
                    ),
                    Tooltip(
                      message: 'Delete Permanently',
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: widget.onDelete,
                        splashRadius: 20,
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
