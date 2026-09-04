import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback? onH1Tap;
  final VoidCallback? onH2Tap;
  final VoidCallback? onH3Tap;
  final VoidCallback? onBulletListTap;
  final VoidCallback? onNumberedListTap;
  final VoidCallback? onCheckboxTap;
  final VoidCallback? onBoldTap;
  final VoidCallback? onItalicTap;
  final VoidCallback? onUnderlineTap;
  final VoidCallback? onStrikethroughTap;
  final VoidCallback? onCodeTap;
  final VoidCallback? onLinkTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onTableTap;
  final VoidCallback? onBlockquoteTap;
  final VoidCallback? onDividerTap;
  final VoidCallback? onClearFormattingTap;

  final int activeHeading; // 0 for none, 1 for H1, 2 for H2, 3 for H3
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrikethrough;
  final bool isCode;
  final bool isBulletList;
  final bool isNumberedList;
  final bool isChecklist;

  const EditorToolbar({
    super.key,
    this.onH1Tap,
    this.onH2Tap,
    this.onH3Tap,
    this.onBulletListTap,
    this.onNumberedListTap,
    this.onCheckboxTap,
    this.onBoldTap,
    this.onItalicTap,
    this.onUnderlineTap,
    this.onStrikethroughTap,
    this.onCodeTap,
    this.onLinkTap,
    this.onImageTap,
    this.onTableTap,
    this.onBlockquoteTap,
    this.onDividerTap,
    this.onClearFormattingTap,
    this.activeHeading = 0,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.isCode = false,
    this.isBulletList = false,
    this.isNumberedList = false,
    this.isChecklist = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? const Color(0xFFD1D5DB) : AppColors.darkText;
    final containerBg = isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF323246) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Headings
            _TextButton(text: 'H1', tooltip: 'Heading 1', isActive: activeHeading == 1, onTap: onH1Tap),
            _TextButton(text: 'H2', tooltip: 'Heading 2', isActive: activeHeading == 2, onTap: onH2Tap),
            _TextButton(text: 'H3', tooltip: 'Heading 3', isActive: activeHeading == 3, onTap: onH3Tap),
            const _Divider(),

            // Lists & Checkbox
            _IconButton(icon: Icons.format_list_bulleted_rounded, tooltip: 'Bulleted List', isActive: isBulletList, onTap: onBulletListTap),
            _IconButton(icon: Icons.format_list_numbered_rounded, tooltip: 'Numbered List', isActive: isNumberedList, onTap: onNumberedListTap),
            _IconButton(icon: Icons.check_box_outlined, tooltip: 'Checklist', isActive: isChecklist, onTap: onCheckboxTap),
            const _Divider(),

            // Text Styles (Bold, Italic, Underline, Strikethrough)
            _IconButton(icon: Icons.format_bold_rounded, tooltip: 'Bold', isActive: isBold, onTap: onBoldTap),
            _IconButton(icon: Icons.format_italic_rounded, tooltip: 'Italic', isActive: isItalic, onTap: onItalicTap),
            _IconButton(icon: Icons.format_underlined_rounded, tooltip: 'Underline', isActive: isUnderline, onTap: onUnderlineTap),
            _IconButton(icon: Icons.strikethrough_s_rounded, tooltip: 'Strikethrough', isActive: isStrikethrough, onTap: onStrikethroughTap),
            const _Divider(),

            // Insert Options (Code, Link, Image, Table)
            _IconButton(icon: Icons.code_rounded, tooltip: 'Code', isActive: isCode, onTap: onCodeTap),
            _IconButton(icon: Icons.link_rounded, tooltip: 'Insert Link', onTap: onLinkTap),
            _IconButton(icon: Icons.image_outlined, tooltip: 'Insert Image', onTap: onImageTap),
            _IconButton(icon: Icons.grid_on_rounded, tooltip: 'Insert Table', onTap: onTableTap),
            const _Divider(),

            // More Options Popup Menu
            PopupMenuButton<String>(
              tooltip: 'More Formatting',
              color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor),
              ),
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.more_horiz_rounded, size: 20, color: iconColor),
              ),
              onSelected: (val) {
                if (val == 'blockquote' && onBlockquoteTap != null) onBlockquoteTap!();
                if (val == 'divider' && onDividerTap != null) onDividerTap!();
                if (val == 'clear' && onClearFormattingTap != null) onClearFormattingTap!();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'blockquote',
                  child: Row(
                    children: [
                      Icon(Icons.format_quote_rounded, size: 18, color: iconColor),
                      const SizedBox(width: 10),
                      Text('Blockquote', style: TextStyle(color: iconColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'divider',
                  child: Row(
                    children: [
                      Icon(Icons.horizontal_rule_rounded, size: 18, color: iconColor),
                      const SizedBox(width: 10),
                      Text('Horizontal Divider', style: TextStyle(color: iconColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.format_clear_rounded, size: 18, color: AppColors.error),
                      SizedBox(width: 10),
                      Text('Clear Formatting', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  final String text;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  const _TextButton({
    required this.text,
    required this.tooltip,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = AppColors.primaryPurple;
    final inactiveBg = Colors.transparent;
    final inactiveText = isDark ? const Color(0xFFD1D5DB) : AppColors.darkText;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isActive ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : inactiveText,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  const _IconButton({
    required this.icon,
    required this.tooltip,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = AppColors.primaryPurple;
    final inactiveBg = Colors.transparent;
    final inactiveIcon = isDark ? const Color(0xFFD1D5DB) : AppColors.darkText;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: isActive ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? Colors.white : inactiveIcon,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 18,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: isDark ? const Color(0xFF323246) : const Color(0xFFE2E8F0),
    );
  }
}


