import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../domain/entities/folder.dart';

class FolderTile extends StatefulWidget {
  final Folder folder;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onAddNote;
  final VoidCallback onDelete;
  final VoidCallback? onRestore;
  final bool isTrashed;

  const FolderTile({
    super.key,
    required this.folder,
    required this.count,
    required this.onTap,
    required this.onAddNote,
    required this.onDelete,
    this.onRestore,
    this.isTrashed = false,
  });

  @override
  State<FolderTile> createState() => _FolderTileState();
}

class _FolderTileState extends State<FolderTile> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dynamic styles based on state
    final double scale = _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0);
    final cardBg = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final hoverCardBg = isDark ? const Color(0xFF25252E) : const Color(0xFFF4F6FA);
    final textColor = isDark ? Colors.white : AppColors.darkText;
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFEAEAEE);
    final hoverBorderColor = widget.folder.color.withOpacity(0.5);

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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _isHovered ? hoverCardBg : cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? hoverBorderColor : borderColor,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.folder.color.withOpacity(_isHovered ? 0.15 : 0.0),
                blurRadius: 15,
                spreadRadius: _isHovered ? 2 : 0,
                offset: const Offset(0, 4),
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.folder.color.withOpacity(_isHovered ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        if (_isHovered)
                          BoxShadow(
                            color: widget.folder.color.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: -2,
                          )
                      ],
                    ),
                    child: Icon(
                      Icons.folder_rounded,
                      color: widget.folder.color,
                      size: 24,
                    ),
                  ),
                  Row(
                    children: [
                      if (widget.isTrashed && widget.onRestore != null)
                        IconButton(
                          tooltip: 'Restore ${widget.folder.name}',
                          icon: Icon(
                            Icons.restore_rounded,
                            size: 26,
                            color: _isHovered ? AppColors.primaryPurple : AppColors.primaryPurple.withOpacity(0.7),
                          ),
                          onPressed: widget.onRestore,
                          splashRadius: 20,
                        ),
                      IconButton(
                        tooltip: widget.isTrashed ? 'Permanently Delete' : 'Delete ${widget.folder.name}',
                        icon: Icon(
                          widget.isTrashed ? Icons.delete_forever_rounded : Icons.delete_outline_rounded,
                          size: 22,
                          color: _isHovered ? AppColors.primaryPink.withOpacity(0.8) : Colors.transparent,
                        ),
                        onPressed: widget.onDelete,
                        splashRadius: 20,
                      ),
                      if (!widget.isTrashed)
                        IconButton(
                          tooltip: 'Add note to ${widget.folder.name}',
                          icon: Icon(
                            Icons.add_circle_rounded,
                            size: 26,
                            color: _isHovered ? AppColors.primaryPink : AppColors.primaryPurple.withOpacity(0.7),
                          ),
                          onPressed: widget.onAddNote,
                          splashRadius: 20,
                        ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.folder.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.count} ${widget.count == 1 ? 'note' : 'notes'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFFA0A0AB) : const Color(0xFF7A869A),
                      fontWeight: FontWeight.w500,
                    ),
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
