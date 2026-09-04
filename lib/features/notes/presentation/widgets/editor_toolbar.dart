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
    final iconColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
              tooltip: 'More',
              color: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              icon: Icon(Icons.more_horiz_rounded, size: 20, color: iconColor),
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
                      Text('Blockquote', style: TextStyle(color: iconColor)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'divider',
                  child: Row(
                    children: [
                      Icon(Icons.horizontal_rule_rounded, size: 18, color: iconColor),
                      const SizedBox(width: 10),
                      Text('Horizontal Divider', style: TextStyle(color: iconColor)),
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
                      Text('Clear Formatting', style: TextStyle(color: AppColors.error)),
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
    final activeBg = isDark
        ? AppColors.primaryPurple.withOpacity(0.25)
        : AppColors.lightLavender;
    final inactiveText = isDark ? AppColors.darkTextPrimary : AppColors.darkText;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.primaryPurple : inactiveText,
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
    final activeBg = isDark
        ? AppColors.primaryPurple.withOpacity(0.25)
        : AppColors.lightLavender;
    final inactiveIcon = isDark ? AppColors.darkTextPrimary : AppColors.darkText;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? AppColors.primaryPurple : inactiveIcon,
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
      color: isDark ? AppColors.darkBorder : const Color(0xFFE2E4E9),
    );
  }
}


