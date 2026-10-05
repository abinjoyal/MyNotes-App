import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../notes/domain/entities/note.dart';
import '../../domain/entities/folder.dart';

class FolderTile extends StatefulWidget {
  final Folder folder;
  final int count;
  final List<Note> previewNotes;
  final VoidCallback onTap;
  final VoidCallback onAddNote;
  final VoidCallback onDelete;
  final VoidCallback? onRestore;
  final VoidCallback? onToggleLock;
  final bool isTrashed;
  final Function(Note)? onNoteSelect;

  const FolderTile({
    super.key,
    required this.folder,
    required this.count,
    this.previewNotes = const [],
    required this.onTap,
    required this.onAddNote,
    required this.onDelete,
    this.onRestore,
    this.onToggleLock,
    this.isTrashed = false,
    this.onNoteSelect,
  });

  @override
  State<FolderTile> createState() => _FolderTileState();
}

class _FolderTileState extends State<FolderTile> {
  bool _isHovered = false;
  bool _isPressed = false;
  int? _hoveredNoteIndex;

  String _getLatestUpdateTime() {
    if (widget.previewNotes.isEmpty) return 'Updated recently';
    String latest = widget.previewNotes.first.updatedAt;
    return 'Updated ${formatRelativeTime(latest)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = colors.isDark;

    final double scale = _isPressed ? 0.98 : (_isHovered ? 1.01 : 1.0);
    final cardBg = Color.alphaBlend(
      widget.folder.color.withOpacity(isDark ? 0.05 : 0.03),
      colors.cardBg,
    );
    final hoverCardBg = Color.alphaBlend(
      widget.folder.color.withOpacity(isDark ? 0.12 : 0.07),
      colors.cardBg,
    );
    final textColor = colors.textColor;
    final subtitleColor = colors.secondaryTextColor;
    final borderColor = colors.borderColor;
    final hoverBorderColor = widget.folder.color.withOpacity(0.8);

    // Extract tags from folder name & preview notes
    final List<String> tags = [];
    tags.add('#${widget.folder.name.toLowerCase().replaceAll(' ', '')}');
    for (final note in widget.previewNotes) {
      for (final tag in note.tags) {
        if (!tags.contains(tag) && tags.length < 3) {
          tags.add(tag.startsWith('#') ? tag : '#$tag');
        }
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _hoveredNoteIndex = null;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(scale),
          transformAlignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _isHovered ? hoverCardBg : cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? hoverBorderColor : borderColor,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              if (_isHovered)
                BoxShadow(
                  color: widget.folder.color.withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            children: [
              // Top Color Accent Bar
              Container(
                height: 3,
                width: double.infinity,
                color: widget.folder.color.withOpacity(_isHovered ? 1.0 : 0.7),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 1. Header (Folder Icon + Title + Count + Lock/Actions)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: widget.folder.color.withOpacity(
                                _isHovered ? 0.25 : 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                if (_isHovered)
                                  BoxShadow(
                                    color: widget.folder.color.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: -1,
                                  ),
                              ],
                            ),
                            child: Icon(
                              Icons.folder_rounded,
                              color: widget.folder.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.folder.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.folder.isLocked) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.lock_rounded,
                                        size: 14,
                                        color: widget.folder.color,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.count} ${widget.count == 1 ? 'note' : 'notes'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.isTrashed)
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded, size: 20, color: subtitleColor),
                              onSelected: (val) {
                                if (val == 'restore' && widget.onRestore != null) {
                                  widget.onRestore!();
                                } else if (val == 'delete') {
                                  widget.onDelete();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'restore',
                                  child: Row(
                                    children: [
                                      Icon(Icons.restore_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text('Restore'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_forever_rounded, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete Permanently', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded, size: 20, color: subtitleColor),
                              onSelected: (val) {
                                if (val == 'lock' && widget.onToggleLock != null) {
                                  widget.onToggleLock!();
                                } else if (val == 'add') {
                                  if (widget.folder.isLocked) {
                                    widget.onTap();
                                  } else {
                                    widget.onAddNote();
                                  }
                                } else if (val == 'delete') {
                                  widget.onDelete();
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'lock',
                                  child: Row(
                                    children: [
                                      Icon(
                                        widget.folder.isLocked
                                            ? Icons.lock_open_rounded
                                            : Icons.lock_rounded,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(widget.folder.isLocked ? 'Unlock Folder' : 'Lock Folder'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'add',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text('Add Note'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete Folder', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 2. Note Items Preview List / Styled Empty State
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withOpacity(0.22)
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: widget.previewNotes.isEmpty
                            ? InkWell(
                                onTap: () {
                                  if (widget.folder.isLocked) {
                                    widget.onTap();
                                  } else {
                                    widget.onAddNote();
                                  }
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.note_add_outlined,
                                        size: 15,
                                        color: widget.folder.color,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Empty — Tap to add first note',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  ...widget.previewNotes.take(2).toList().asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final note = entry.value;
                                    final titleText = note.title.trim().isEmpty ? 'Untitled Note' : note.title;
                                    final isItemHovered = _hoveredNoteIndex == idx;

                                    return MouseRegion(
                                      onEnter: (_) => setState(() => _hoveredNoteIndex = idx),
                                      onExit: (_) => setState(() => _hoveredNoteIndex = null),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: InkWell(
                                          onTap: () {
                                            if (widget.folder.isLocked) {
                                              widget.onTap();
                                            } else if (widget.onNoteSelect != null) {
                                              widget.onNoteSelect!(note);
                                            } else {
                                              widget.onTap();
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 150),
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isItemHovered
                                                  ? widget.folder.color.withOpacity(0.12)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.description_outlined,
                                                  size: 14,
                                                  color: isItemHovered
                                                      ? widget.folder.color
                                                      : subtitleColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    titleText,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isItemHovered
                                                          ? textColor
                                                          : textColor.withOpacity(0.9),
                                                      fontWeight: isItemHovered
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isItemHovered)
                                                  Icon(
                                                    Icons.chevron_right_rounded,
                                                    size: 14,
                                                    color: widget.folder.color,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  InkWell(
                                    onTap: () {
                                      if (widget.folder.isLocked) {
                                        widget.onTap();
                                      } else {
                                        widget.onAddNote();
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add_rounded,
                                            size: 14,
                                            color: widget.folder.color,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Add note...',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: widget.folder.color.withOpacity(0.9),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 8),

                      // 3. Footer (Relative Time + Tag Pills)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: subtitleColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getLatestUpdateTime(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 4,
                            children: tags.take(2).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.folder.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: widget.folder.color,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
