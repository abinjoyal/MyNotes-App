import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/theme/app_theme_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = colors.isDark;

    final double scale = _isPressed ? 0.98 : (_isHovered ? 1.01 : 1.0);
    final cardBg = colors.cardBg;
    final hoverCardBg = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFE8DFC0);
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
      onExit: (_) => setState(() => _isHovered = false),
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
          padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Header (Folder Icon + Title + Count + Lock/Actions)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
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
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                                  fontSize: 16,
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
                          widget.onAddNote();
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
              const SizedBox(height: 12),

              // 2. Note Items Preview List
              Container(
                padding: const EdgeInsets.all(10),
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
                child: Column(
                  children: [
                    ...widget.previewNotes.take(2).map((note) {
                      final titleText = note.title.trim().isEmpty ? 'Untitled Note' : note.title;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: InkWell(
                          onTap: () {
                            if (widget.onNoteSelect != null) {
                              widget.onNoteSelect!(note);
                            } else {
                              widget.onTap();
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 15,
                                color: subtitleColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  titleText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    InkWell(
                      onTap: widget.onAddNote,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 15,
                              color: subtitleColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add more notes...',
                              style: TextStyle(
                                fontSize: 13,
                                color: subtitleColor.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Footer (Updated Time + Tag Pills)
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
                      const SizedBox(width: 5),
                      Text(
                        'Updated recently',
                        style: TextStyle(
                          fontSize: 11,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
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
    );
  }
}
