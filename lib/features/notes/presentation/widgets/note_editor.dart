import 'package:flutter/material.dart';
import 'package:mynotes/features/notes/data/services/version_history_service.dart';
import '../../../../app/constants/app_colors.dart';
import '../../domain/entities/note.dart';
import 'editor_toolbar.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../core/services/export_service.dart';

class _MarkerMatch {
  final int start;
  final int end;
  final String openTag;
  final String closeTag;
  final String innerText;
  final String type; // 'bold', 'italic', 'underline', 'strike', 'code'

  _MarkerMatch({
    required this.start,
    required this.end,
    required this.openTag,
    required this.closeTag,
    required this.innerText,
    required this.type,
  });
}

class MarkdownEditingController extends TextEditingController {
  MarkdownEditingController({super.text});

  static TextDecoration _combineDecorations(
    TextDecoration? d1,
    TextDecoration d2,
  ) {
    if (d1 == null || d1 == TextDecoration.none) return d2;
    return TextDecoration.combine([d1, d2]);
  }

  static _MarkerMatch? _findFirstMatch(String text) {
    final matches = <_MarkerMatch>[];

    // 1. Code: `...`
    final codeReg = RegExp(r'`([^`\n]+)`');
    for (final m in codeReg.allMatches(text)) {
      matches.add(
        _MarkerMatch(
          start: m.start,
          end: m.end,
          openTag: '`',
          closeTag: '`',
          innerText: m.group(1)!,
          type: 'code',
        ),
      );
    }

    // 2. Bold: **...**
    final boldReg = RegExp(r'\*\*([^\*\n]+)\*\*');
    for (final m in boldReg.allMatches(text)) {
      matches.add(
        _MarkerMatch(
          start: m.start,
          end: m.end,
          openTag: '**',
          closeTag: '**',
          innerText: m.group(1)!,
          type: 'bold',
        ),
      );
    }

    // 3. Underline: <u>...</u>
    final underlineReg = RegExp(r'<u>(.*?)<\/u>', caseSensitive: false);
    for (final m in underlineReg.allMatches(text)) {
      final fullMatch = m.group(0)!;
      matches.add(
        _MarkerMatch(
          start: m.start,
          end: m.end,
          openTag: fullMatch.substring(0, 3),
          closeTag: fullMatch.substring(fullMatch.length - 4),
          innerText: m.group(1)!,
          type: 'underline',
        ),
      );
    }

    // 4. Strikethrough: ~~...~~ or ~...~
    final strikeReg = RegExp(r'~~([^~\n]+)~~|~([^~\n]+)~');
    for (final m in strikeReg.allMatches(text)) {
      final fullMatch = m.group(0)!;
      String open = fullMatch.startsWith('~~') ? '~~' : '~';
      String content = m.group(1) ?? m.group(2) ?? '';
      matches.add(
        _MarkerMatch(
          start: m.start,
          end: m.end,
          openTag: open,
          closeTag: open,
          innerText: content,
          type: 'strike',
        ),
      );
    }

    // 5. Italic: *...* (ensure not starting/ending with **)
    final italicReg = RegExp(r'(?<!\*)\*([^\*\n]+)\*(?!\*)');
    for (final m in italicReg.allMatches(text)) {
      matches.add(
        _MarkerMatch(
          start: m.start,
          end: m.end,
          openTag: '*',
          closeTag: '*',
          innerText: m.group(1)!,
          type: 'italic',
        ),
      );
    }

    if (matches.isEmpty) return null;

    matches.sort((a, b) {
      if (a.start != b.start) return a.start.compareTo(b.start);
      return b.end.compareTo(a.end);
    });

    return matches.first;
  }

  static List<InlineSpan> _parseInline(String text, TextStyle currentStyle) {
    if (text.isEmpty) return [];

    final firstMatch = _findFirstMatch(text);
    if (firstMatch == null) {
      return [TextSpan(text: text, style: currentStyle)];
    }

    final List<InlineSpan> spans = [];
    const tagStyle = TextStyle(fontSize: 0.001, color: Colors.transparent);

    // Text before match
    if (firstMatch.start > 0) {
      spans.addAll(
        _parseInline(text.substring(0, firstMatch.start), currentStyle),
      );
    }

    // Opening tag (always hidden from UI display)
    spans.add(TextSpan(text: firstMatch.openTag, style: tagStyle));

    // Compute inner style
    TextStyle innerStyle = currentStyle;
    switch (firstMatch.type) {
      case 'bold':
        innerStyle = innerStyle.copyWith(fontWeight: FontWeight.bold);
        break;
      case 'italic':
        innerStyle = innerStyle.copyWith(fontStyle: FontStyle.italic);
        break;
      case 'underline':
        innerStyle = innerStyle.copyWith(
          decoration: _combineDecorations(
            innerStyle.decoration,
            TextDecoration.underline,
          ),
        );
        break;
      case 'strike':
        innerStyle = innerStyle.copyWith(
          decoration: _combineDecorations(
            innerStyle.decoration,
            TextDecoration.lineThrough,
          ),
        );
        break;
      case 'code':
        innerStyle = innerStyle.copyWith(
          backgroundColor: const Color(0xFFF0F0F3),
          color: AppColors.primaryPurple,
          fontFamily: 'monospace',
        );
        break;
    }

    // Recursively parse inner content
    if (firstMatch.innerText.isNotEmpty) {
      spans.addAll(_parseInline(firstMatch.innerText, innerStyle));
    }

    // Closing tag (always hidden from UI display)
    spans.add(TextSpan(text: firstMatch.closeTag, style: tagStyle));

    // Text after match
    if (firstMatch.end < text.length) {
      spans.addAll(_parseInline(text.substring(firstMatch.end), currentStyle));
    }

    return spans;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = this.text;
    if (text.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hiddenPrefixStyle = const TextStyle(
      fontSize: 0.001,
      color: Colors.transparent,
    );
    final defaultStyle =
        style ??
        TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.darkText,
          fontSize: SettingsController.instance.fontSizeValue,
        );
    final List<InlineSpan> spans = [];

    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLastLine = i == lines.length - 1;

      if (line.isEmpty) {
        if (!isLastLine) {
          spans.add(TextSpan(text: '\n', style: defaultStyle));
        }
        continue;
      }

      if (line.startsWith('# ')) {
        // H1: 24px, bold, height: 1.4
        final lineStyle = defaultStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.4,
          color: defaultStyle.color,
        );
        spans.add(TextSpan(text: '# ', style: hiddenPrefixStyle));
        spans.addAll(_parseInline(line.substring(2), lineStyle));
      } else if (line.startsWith('## ')) {
        // H2: 20px, bold, height: 1.3
        final lineStyle = defaultStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.3,
          color: defaultStyle.color,
        );
        spans.add(TextSpan(text: '## ', style: hiddenPrefixStyle));
        spans.addAll(_parseInline(line.substring(3), lineStyle));
      } else if (line.startsWith('### ')) {
        // H3: 17px, bold, height: 1.3
        final lineStyle = defaultStyle.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          height: 1.3,
          color: defaultStyle.color,
        );
        spans.add(TextSpan(text: '### ', style: hiddenPrefixStyle));
        spans.addAll(_parseInline(line.substring(4), lineStyle));
      } else if (line.startsWith('- [x] ') || line.startsWith('- [X] ')) {
        // Completed Checklist Item
        spans.add(
          const TextSpan(
            text: '☑ ',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
        spans.add(const TextSpan(text: '    ', style: TextStyle(fontSize: 15)));
        final lineStyle = defaultStyle.copyWith(
          decoration: TextDecoration.lineThrough,
          color: AppColors.lightText,
        );
        spans.addAll(_parseInline(line.substring(6), lineStyle));
      } else if (line.startsWith('- [ ] ')) {
        // Unchecked Checklist Item
        spans.add(
          const TextSpan(
            text: '☐ ',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
        spans.add(const TextSpan(text: '    ', style: TextStyle(fontSize: 15)));
        spans.addAll(_parseInline(line.substring(6), defaultStyle));
      } else if (line.startsWith('• ')) {
        // Bullet List
        spans.add(
          const TextSpan(
            text: '• ',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        );
        spans.addAll(_parseInline(line.substring(2), defaultStyle));
      } else if (line.startsWith('- ')) {
        // Dash Bullet List
        spans.add(
          const TextSpan(
            text: '- ',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        );
        spans.addAll(_parseInline(line.substring(2), defaultStyle));
      } else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        final match = RegExp(r'^\d+\. ').firstMatch(line)!;
        final prefix = match.group(0)!;
        spans.add(
          TextSpan(
            text: prefix,
            style: const TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        );
        spans.addAll(_parseInline(line.substring(prefix.length), defaultStyle));
      } else if (line.startsWith('> ')) {
        // Blockquote
        spans.add(
          const TextSpan(
            text: '> ',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
        final lineStyle = defaultStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: AppColors.secondaryText,
        );
        spans.addAll(_parseInline(line.substring(2), lineStyle));
      } else if (line.startsWith('|') && line.contains('|')) {
        // Table row or separator
        final isSeparator = RegExp(r'^\|[\s:\-|\+]+\|\s*$').hasMatch(line);
        if (isSeparator) {
          spans.add(
            TextSpan(
              text: line,
              style: const TextStyle(
                color: Color(0xFFD0D5DD),
                fontWeight: FontWeight.w300,
                fontSize: 12,
              ),
            ),
          );
        } else {
          final cells = line.split('|');
          for (int cIdx = 0; cIdx < cells.length; cIdx++) {
            if (cIdx == 0) {
              spans.add(
                const TextSpan(
                  text: '│ ',
                  style: TextStyle(
                    color: Color(0xFF635BFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            } else if (cIdx == cells.length - 1) {
              spans.add(
                const TextSpan(
                  text: ' │',
                  style: TextStyle(
                    color: Color(0xFF635BFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            } else {
              final cellText = cells[cIdx];
              spans.addAll(_parseInline(cellText, defaultStyle));
              if (cIdx < cells.length - 2) {
                spans.add(
                  const TextSpan(
                    text: ' │ ',
                    style: TextStyle(
                      color: Color(0xFFD0D5DD),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            }
          }
        }
      } else {
        // Normal line
        spans.addAll(_parseInline(line, defaultStyle));
      }

      if (!isLastLine) {
        spans.add(TextSpan(text: '\n', style: defaultStyle));
      }
    }

    return TextSpan(style: style, children: spans);
  }
}

class NoteEditor extends StatefulWidget {
  final Note? initialNote;
  final Function(
    String title,
    String content,
    Color color,
    List<String> tags,
    bool isPinned,
  )?
  onSave;
  final VoidCallback? onClose;

  const NoteEditor({super.key, this.initialNote, this.onSave, this.onClose});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late MarkdownEditingController _contentController;
  late Color _selectedColor;
  late List<String> _tags;
  bool _isPinned = false;
  String _previousText = '';
  final ScreenshotController _screenshotController = ScreenshotController();

  // Active formatting state for toolbar highlights
  int _activeHeading = 0;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;
  bool _isCode = false;
  bool _isBulletList = false;
  bool _isNumberedList = false;
  bool _isChecklist = false;

  final List<Color> _categoryColors = const [
    Color(0xFF635BFF),
    Color(0xFF4C6FFF),
    Color(0xFFFF4B4B),
    Color(0xFFFFB020),
    Color(0xFF00C853),
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    SettingsController.instance.addListener(_onSettingsChanged);
  }

  void _initControllers() {
    _titleController = TextEditingController(
      text: widget.initialNote?.title ?? '',
    );
    _contentController = MarkdownEditingController(
      text: widget.initialNote?.content ?? '',
    );
    _previousText = _contentController.text;
    _contentController.addListener(_onContentChanged);
    _selectedColor =
        widget.initialNote?.indicatorColor ?? const Color(0xFF635BFF);
    _tags = List.from(widget.initialNote?.tags ?? ['#new']);
    _isPinned = widget.initialNote?.isPinned ?? false;
  }

  @override
  void didUpdateWidget(covariant NoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialNote?.id != widget.initialNote?.id) {
      _contentController.removeListener(_onContentChanged);
      _titleController.dispose();
      _contentController.dispose();
      _initControllers();
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    SettingsController.instance.removeListener(_onSettingsChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  void _onContentChanged() {
    final currentText = _contentController.text;

    // Handle Smart Enter List/Heading continuation
    if (currentText.length > _previousText.length &&
        currentText.endsWith('\n')) {
      _handleSmartEnter(_previousText);
    } else if (currentText.length < _previousText.length) {
      _handleSmartBackspace(_previousText);
    }
    _previousText = currentText;

    // Recalculate active toolbar formats
    _updateActiveToolbarStates();
    setState(() {});
  }

  void _handleSmartBackspace(String oldText) {
    final selection = _contentController.selection;
    int cursor = selection.baseOffset;
    if (cursor < 0) return;

    int lineStart = _getLineStart(oldText, cursor);
    int lineEnd = _getLineEnd(oldText, cursor);
    if (lineStart > lineEnd || lineEnd > oldText.length) return;

    String oldLine = oldText.substring(lineStart, lineEnd);
    if (oldLine == '- [ ]' ||
        oldLine == '- [' ||
        oldLine == '- [x]' ||
        oldLine == '•' ||
        oldLine == '-' ||
        oldLine == '>') {
      final newText = oldText.replaceRange(lineStart, lineEnd, '');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: lineStart),
      );
    }
  }

  int _getLineStart(String text, int offset) {
    if (offset <= 0) return 0;
    if (offset > text.length) offset = text.length;
    int idx = text.lastIndexOf('\n', offset - 1);
    return (idx == -1) ? 0 : idx + 1;
  }

  int _getLineEnd(String text, int offset) {
    if (offset < 0) return 0;
    if (offset >= text.length) return text.length;
    int idx = text.indexOf('\n', offset);
    return (idx == -1) ? text.length : idx;
  }

  void _handleSmartEnter(String oldText) {
    final selection = _contentController.selection;
    int cursor = selection.baseOffset;
    if (cursor <= 1 || cursor > oldText.length + 1) return;

    // Find the line just before newline
    int prevLineEnd = cursor - 1;
    if (prevLineEnd > oldText.length) prevLineEnd = oldText.length;
    int prevLineStart = _getLineStart(oldText, prevLineEnd);

    if (prevLineStart >= prevLineEnd || prevLineEnd > oldText.length) return;

    String prevLine = oldText.substring(prevLineStart, prevLineEnd).trimRight();

    if (prevLine.startsWith('- [ ] ') ||
        prevLine.startsWith('- [x] ') ||
        prevLine.startsWith('- [X] ')) {
      if (prevLine == '- [ ]' ||
          prevLine == '- [x]' ||
          prevLine == '- [X]' ||
          prevLine == '- [ ] ' ||
          prevLine == '- [x] ') {
        // Exit checklist on double enter
        _contentController.value = TextEditingValue(
          text: oldText.replaceRange(prevLineStart, prevLineEnd + 1, ''),
          selection: TextSelection.collapsed(offset: prevLineStart),
        );
      } else {
        _insertStringAtCursor('- [ ] ');
      }
    } else if (prevLine.startsWith('• ')) {
      if (prevLine == '•' || prevLine == '• ') {
        _contentController.value = TextEditingValue(
          text: oldText.replaceRange(prevLineStart, prevLineEnd + 1, ''),
          selection: TextSelection.collapsed(offset: prevLineStart),
        );
      } else {
        _insertStringAtCursor('• ');
      }
    } else if (prevLine.startsWith('- ')) {
      if (prevLine == '-' || prevLine == '- ') {
        _contentController.value = TextEditingValue(
          text: oldText.replaceRange(prevLineStart, prevLineEnd + 1, ''),
          selection: TextSelection.collapsed(offset: prevLineStart),
        );
      } else {
        _insertStringAtCursor('- ');
      }
    } else if (RegExp(r'^\d+\. ').hasMatch(prevLine)) {
      final match = RegExp(r'^(\d+)\. ').firstMatch(prevLine);
      if (match != null) {
        int num = int.parse(match.group(1)!);
        if (prevLine == '$num.' || prevLine == '$num. ') {
          _contentController.value = TextEditingValue(
            text: oldText.replaceRange(prevLineStart, prevLineEnd + 1, ''),
            selection: TextSelection.collapsed(offset: prevLineStart),
          );
        } else {
          _insertStringAtCursor('${num + 1}. ');
        }
      }
    } else if (prevLine.startsWith('> ')) {
      if (prevLine == '>' || prevLine == '> ') {
        _contentController.value = TextEditingValue(
          text: oldText.replaceRange(prevLineStart, prevLineEnd + 1, ''),
          selection: TextSelection.collapsed(offset: prevLineStart),
        );
      } else {
        _insertStringAtCursor('> ');
      }
    }
  }

  void _insertStringAtCursor(String str) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    int start = selection.start;
    if (start < 0 || start > text.length) start = text.length;

    final newText = text.replaceRange(start, start, str);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + str.length),
    );
  }

  void _updateActiveToolbarStates() {
    final text = _contentController.text;
    final selection = _contentController.selection;

    int cursor = selection.baseOffset;
    if (cursor < 0 || cursor > text.length) {
      _activeHeading = 0;
      _isBold = false;
      _isItalic = false;
      _isUnderline = false;
      _isStrikethrough = false;
      _isCode = false;
      _isBulletList = false;
      _isNumberedList = false;
      _isChecklist = false;
      return;
    }

    // Line level block check
    int lineStart = _getLineStart(text, cursor);
    int lineEnd = _getLineEnd(text, cursor);

    String lineText = (lineStart <= lineEnd && lineEnd <= text.length)
        ? text.substring(lineStart, lineEnd)
        : '';

    if (lineText.startsWith('# ')) {
      _activeHeading = 1;
    } else if (lineText.startsWith('## ')) {
      _activeHeading = 2;
    } else if (lineText.startsWith('### ')) {
      _activeHeading = 3;
    } else {
      _activeHeading = 0;
    }

    _isBulletList = lineText.startsWith('• ') || lineText.startsWith('- ');
    _isNumberedList = RegExp(r'^\d+\. ').hasMatch(lineText);
    _isChecklist =
        lineText.startsWith('- [ ] ') || lineText.startsWith('- [x] ');

    // Inline style check
    _isBold = _isInsideMarker(text, cursor, '**', '**');
    _isItalic = _isInsideMarker(text, cursor, '*', '*');
    _isUnderline = _isInsideMarker(text, cursor, '<u>', '</u>');
    _isStrikethrough =
        _isInsideMarker(text, cursor, '~~', '~~') ||
        _isInsideMarker(text, cursor, '~', '~');
    _isCode = _isInsideMarker(text, cursor, '`', '`');
  }

  bool _isInsideMarker(
    String text,
    int cursor,
    String openTag,
    String closeTag,
  ) {
    if (cursor < 0 || cursor > text.length) return false;
    int lineStart = _getLineStart(text, cursor);
    int lineEnd = _getLineEnd(text, cursor);
    String lineText = text.substring(lineStart, lineEnd);
    int relCursor = cursor - lineStart;

    int searchOffset = relCursor > 0 ? relCursor - 1 : 0;
    int open = lineText.lastIndexOf(openTag, searchOffset);
    if (open == -1) return false;

    int close = lineText.indexOf(closeTag, open + openTag.length);
    if (close == -1) return false;

    return (relCursor >= open + openTag.length && relCursor <= close);
  }

  // --- REUSABLE HELPER METHODS ---

  bool _isWordChar(String ch) {
    return RegExp(r'[a-zA-Z0-9_\u0900-\u0D7F]').hasMatch(ch);
  }

  void _applyHeading(int level) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    int cursorOffset = selection.baseOffset;
    if (cursorOffset < 0 || cursorOffset > text.length) {
      cursorOffset = text.length;
    }

    int lineStart = _getLineStart(text, cursorOffset);
    int lineEnd = _getLineEnd(text, cursorOffset);

    String lineText = text.substring(lineStart, lineEnd);
    String targetPrefix = level == 1
        ? '# '
        : level == 2
        ? '## '
        : '### ';

    final prefixes = [
      '# ',
      '## ',
      '### ',
      '• ',
      '- ',
      '1. ',
      '- [ ] ',
      '- [x] ',
    ];
    String currentPrefix = '';

    for (final p in prefixes) {
      if (lineText.startsWith(p)) {
        currentPrefix = p;
        break;
      }
    }

    String contentWithoutPrefix = lineText;
    if (currentPrefix.isNotEmpty) {
      contentWithoutPrefix = lineText.substring(currentPrefix.length);
    }

    String newLineText = '';
    if (currentPrefix == targetPrefix) {
      // Toggle off to normal paragraph
      newLineText = contentWithoutPrefix;
    } else {
      // Set to new heading level
      newLineText = '$targetPrefix$contentWithoutPrefix';
    }

    final newText = text.replaceRange(lineStart, lineEnd, newLineText);
    final newCursorOffset = lineStart + newLineText.length;

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }

  void _toggleInlineFormatting(String openTag, String closeTag) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0 || start > text.length || end > text.length) {
      start = text.length;
      end = text.length;
    }
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    // If selection is collapsed (cursor only), check if cursor is on a word or between empty tags
    if (start == end) {
      int cursor = start;
      if (cursor >= 0 && cursor <= text.length) {
        // Check if cursor is immediately between empty tags (e.g. **|**)
        bool hasOuterOpenBefore =
            cursor >= openTag.length &&
            text.substring(cursor - openTag.length, cursor) == openTag;
        bool hasOuterCloseAfter =
            cursor + closeTag.length <= text.length &&
            text.substring(cursor, cursor + closeTag.length) == closeTag;

        if (hasOuterOpenBefore && hasOuterCloseAfter) {
          // Remove empty tags
          final newText = text.replaceRange(
            cursor - openTag.length,
            cursor + closeTag.length,
            '',
          );
          _contentController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: cursor - openTag.length),
          );
          return;
        }

        // Expand selection to word bounds if cursor touches a word
        int wStart = cursor;
        int wEnd = cursor;
        while (wStart > 0 && _isWordChar(text[wStart - 1])) {
          wStart--;
        }
        while (wEnd < text.length && _isWordChar(text[wEnd])) {
          wEnd++;
        }

        if (wStart < wEnd) {
          start = wStart;
          end = wEnd;
        }
      }
    }

    if (start != end) {
      final selectedText = text.substring(start, end);

      bool isDirectlyWrapped =
          selectedText.startsWith(openTag) &&
          selectedText.endsWith(closeTag) &&
          selectedText.length >= (openTag.length + closeTag.length);
      bool hasOuterOpen =
          start >= openTag.length &&
          text.substring(start - openTag.length, start) == openTag;
      bool hasOuterClose =
          end + closeTag.length <= text.length &&
          text.substring(end, end + closeTag.length) == closeTag;

      if (isDirectlyWrapped) {
        // Unwrap direct tags
        final unwrapped = selectedText.substring(
          openTag.length,
          selectedText.length - closeTag.length,
        );
        final newText = text.replaceRange(start, end, unwrapped);
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: start,
            extentOffset: start + unwrapped.length,
          ),
        );
      } else if (hasOuterOpen && hasOuterClose) {
        // Unwrap outer tags around selection
        final newText = text
            .replaceRange(end, end + closeTag.length, '')
            .replaceRange(start - openTag.length, start, '');
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: start - openTag.length,
            extentOffset: end - openTag.length,
          ),
        );
      } else {
        // Wrap with tags
        final replacement = '$openTag$selectedText$closeTag';
        final newText = text.replaceRange(start, end, replacement);
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: start + openTag.length,
            extentOffset: start + openTag.length + selectedText.length,
          ),
        );
      }
    } else {
      // Empty selection on empty space: insert tags and collapse inside
      final replacement = '$openTag$closeTag';
      final newText = text.replaceRange(start, end, replacement);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + openTag.length),
      );
    }
  }

  void _toggleBold() => _toggleInlineFormatting('**', '**');
  void _toggleItalic() => _toggleInlineFormatting('*', '*');
  void _toggleUnderline() => _toggleInlineFormatting('<u>', '</u>');
  void _toggleStrikethrough() => _toggleInlineFormatting('~~', '~~');
  void _toggleCode() => _toggleInlineFormatting('`', '`');

  void _onTextFieldTap() {
    final text = _contentController.text;
    final selection = _contentController.selection;
    int cursor = selection.baseOffset;
    if (cursor < 0 || cursor > text.length) return;

    int lineStart = _getLineStart(text, cursor);
    int lineEnd = _getLineEnd(text, cursor);
    String lineText = text.substring(lineStart, lineEnd);
    int relOffset = cursor - lineStart;

    if (relOffset <= 6) {
      if (lineText.startsWith('- [ ] ')) {
        final newLine = lineText.replaceRange(0, 6, '- [x] ');
        final newText = text.replaceRange(lineStart, lineEnd, newLine);
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: lineStart + newLine.length,
          ),
        );
      } else if (lineText.startsWith('- [x] ') ||
          lineText.startsWith('- [X] ')) {
        final newLine = lineText.replaceRange(0, 6, '- [ ] ');
        final newText = text.replaceRange(lineStart, lineEnd, newLine);
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: lineStart + newLine.length,
          ),
        );
      }
    }
  }

  void _toggleBlockPrefix(String prefix) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0 || start > text.length || end > text.length) {
      start = text.length;
      end = text.length;
    }
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    int lineStart = _getLineStart(text, start);
    int lineEnd = _getLineEnd(text, end);

    String blockText = text.substring(lineStart, lineEnd);
    List<String> lines = blockText.split('\n');

    final prefixes = [
      '- [ ] ',
      '- [x] ',
      '- [X] ',
      '### ',
      '## ',
      '# ',
      '• ',
      '- ',
      '> ',
    ];

    bool allHavePrefix = lines.every((line) {
      if (line.trim().isEmpty) return true;
      return line.startsWith(prefix);
    });

    List<String> newLines = [];
    for (String line in lines) {
      if (line.trim().isEmpty && lines.length > 1) {
        newLines.add(line);
        continue;
      }

      String currentPrefix = '';
      for (final p in prefixes) {
        if (line.startsWith(p)) {
          currentPrefix = p;
          break;
        }
      }
      if (currentPrefix.isEmpty && RegExp(r'^\d+\. ').hasMatch(line)) {
        final match = RegExp(r'^\d+\. ').firstMatch(line);
        if (match != null) {
          currentPrefix = match.group(0)!;
        }
      }

      String contentWithoutPrefix = currentPrefix.isNotEmpty
          ? line.substring(currentPrefix.length)
          : line;

      if (allHavePrefix) {
        newLines.add(contentWithoutPrefix);
      } else {
        newLines.add('$prefix$contentWithoutPrefix');
      }
    }

    String newBlockText = newLines.join('\n');
    final newText = text.replaceRange(lineStart, lineEnd, newBlockText);

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: lineStart,
        extentOffset: lineStart + newBlockText.length,
      ),
    );
  }

  void _toggleBulletList() => _toggleBlockPrefix('• ');
  void _toggleNumberedList() => _toggleBlockPrefix('1. ');
  void _toggleChecklist() => _toggleBlockPrefix('- [ ] ');
  void _insertBlockquote() => _toggleBlockPrefix('> ');

  void _insertDivider() {
    final text = _contentController.text;
    final selection = _contentController.selection;
    int start = selection.start;
    if (start < 0) start = text.length;

    const div = '\n---\n';
    final newText = text.replaceRange(start, start, div);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + div.length),
    );
  }

  void _insertLink() {
    final textController = TextEditingController();
    final urlController = TextEditingController(text: 'https://');

    final selection = _contentController.selection;
    if (selection.start >= 0 && selection.end > selection.start) {
      textController.text = _contentController.text.substring(
        selection.start,
        selection.end,
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Insert Link',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Text',
                hintText: 'Link text',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final linkText = textController.text.isEmpty
                  ? 'link'
                  : textController.text;
              final url = urlController.text.isEmpty
                  ? 'https://'
                  : urlController.text;
              _toggleInlineFormatting('[$linkText](', '$url)');
            },
            child: const Text('Insert Link'),
          ),
        ],
      ),
    );
  }

  void _insertImage() {
    final altController = TextEditingController(text: 'image');
    final urlController = TextEditingController(text: 'https://');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Insert Image',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: altController,
              decoration: const InputDecoration(labelText: 'Alt Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'Image Path or URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final alt = altController.text.isEmpty
                  ? 'image'
                  : altController.text;
              final url = urlController.text;
              _toggleInlineFormatting('![$alt](', '$url)');
            },
            child: const Text('Insert Image'),
          ),
        ],
      ),
    );
  }

  void _insertTable() {
    final rowsController = TextEditingController(text: '3');
    final colsController = TextEditingController(text: '3');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Insert Table',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: rowsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rows'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: colsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Columns'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              
            ),
            onPressed: () {
              Navigator.pop(ctx);
              int r = int.tryParse(rowsController.text) ?? 3;
              int c = int.tryParse(colsController.text) ?? 3;
              if (r < 1) r = 1;
              if (c < 1) c = 1;

              StringBuffer sb = StringBuffer('\n');
              // Header
              sb.write('|');
              for (int i = 1; i <= c; i++) {
                sb.write(' Column $i |');
              }
              sb.write('\n|');
              for (int i = 1; i <= c; i++) {
                sb.write('----------|');
              }
              sb.write('\n');
              // Rows
              for (int j = 0; j < r - 1; j++) {
                sb.write('|');
                for (int i = 1; i <= c; i++) {
                  sb.write('          |');
                }
                sb.write('\n');
              }

              _insertStringAtCursor(sb.toString());
            },
            child: const Text('Insert Table'),
          ),
        ],
      ),
    );
  }

  void _clearFormatting() {
    final text = _contentController.text;
    final selection = _contentController.selection;
    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0 || start > text.length || end > text.length) {
      start = 0;
      end = text.length;
    }
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    String selectedText = text.substring(start, end);

    // Strip markdown formatting symbols
    selectedText = selectedText.replaceAll(RegExp(r'[\*\~`_]'), '');
    selectedText = selectedText.replaceAll(RegExp(r'<\/?u>'), '');
    selectedText = selectedText.replaceAll(
      RegExp(r'^#{1,3}\s+', multiLine: true),
      '',
    );
    selectedText = selectedText.replaceAll(
      RegExp(r'^[•\-]\s+', multiLine: true),
      '',
    );
    selectedText = selectedText.replaceAll(
      RegExp(r'^\d+\.\s+', multiLine: true),
      '',
    );
    selectedText = selectedText.replaceAll(
      RegExp(r'^-\s*\[[xX\s]\]\s+', multiLine: true),
      '',
    );

    final newText = text.replaceRange(start, end, selectedText);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start,
        extentOffset: start + selectedText.length,
      ),
    );
  }

  int get _wordCount {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _charCount => _contentController.text.length;

  int get _readingTimeMinutes {
    final words = _wordCount;
    if (words == 0) return 0;
    final mins = (words / 200).ceil();
    return mins < 1 ? 1 : mins;
  }

  void _showAddTagDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF323246) : const Color(0xFFE5E7EB),
          ),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.label_outline_rounded,
              color: AppColors.primaryPurple,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Add New Tag',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: tagController,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'e.g. #work, #idea, #important',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey : Colors.grey[600],
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              var text = tagController.text.trim();
              if (text.isNotEmpty) {
                if (!text.startsWith('#')) text = '#$text';
                setState(() {
                  if (!_tags.contains(text)) {
                    _tags.add(text);
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Tag'),
          ),
        ],
      ),
    );
  }

  void _showVersionHistoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF262636) : const Color(0xFFF3F4F6);
    final borderColor = isDark
        ? const Color(0xFF323246)
        : const Color(0xFFE5E7EB);

    final noteId = widget.initialNote?.id ?? '';
    final snapshots = VersionHistoryService.instance.getHistoryForNote(noteId);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor, width: 1),
          ),
          elevation: 16,
          child: Container(
            width: 500,
            height: 580,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: AppColors.primaryPurple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Version History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              '${snapshots.length} saved version snapshots',
                              style: TextStyle(
                                fontSize: 12,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: subtextColor,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Snapshots List
                Expanded(
                  child: snapshots.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_toggle_off_rounded,
                                size: 48,
                                color: subtextColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No previous versions saved yet.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Version snapshots are automatically saved whenever you edit & save notes.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: snapshots.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final snapshot = snapshots[idx];
                            final isCurrent = idx == 0;

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isCurrent
                                      ? AppColors.primaryPurple.withOpacity(0.5)
                                      : borderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: isCurrent
                                                ? AppColors.primaryPurple
                                                : subtextColor,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            snapshot.timestamp,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isCurrent
                                                  ? AppColors.primaryPurple
                                                  : subtextColor,
                                            ),
                                          ),
                                          if (isCurrent) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryPurple
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Current',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppColors.primaryPurple,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        '${snapshot.wordCount} words',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: subtextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    snapshot.title.isEmpty
                                        ? 'Untitled Note'
                                        : snapshot.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  if (snapshot.content.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      snapshot.content.trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subtextColor,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          setState(() {
                                            _titleController.text =
                                                snapshot.title;
                                            _contentController.text =
                                                snapshot.content;
                                            _selectedColor =
                                                snapshot.indicatorColor;
                                            _tags = List.from(snapshot.tags);
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Restored note version from ${snapshot.timestamp}',
                                              ),
                                              backgroundColor:
                                                  AppColors.primaryPurple,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.restore_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Restore Version',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryPurple,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBadge(String label, bool isDark, Color subtextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3A) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: subtextColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final subtextColor = isDark ? AppColors.lightText : const Color(0xFF6C757D);
    final hintColor = isDark
        ? AppColors.lightText.withOpacity(0.6)
        : const Color(0xFF98A2B3);

    return Container(
      color: isDark ? AppColors.darkScaffoldBackground : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Bar with Back Button & Auto-Save Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E2A)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF323246)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: textColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'All Notes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  // History Button
                  OutlinedButton.icon(
                    onPressed: _showVersionHistoryDialog,
                    icon: const Icon(
                      Icons.history_rounded,
                      size: 16,
                      color: AppColors.primaryPurple,
                    ),
                    label: const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF323246)
                            : const Color(0xFFE5E7EB),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Auto-Save Status Indicator Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF14532D).withOpacity(0.3)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF16A34A).withOpacity(0.4)
                            : const Color(0xFFDCFCE7),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Saved',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Share Button
                  IconButton(
                    onPressed: () async {
                      final title = _titleController.text.trim();
                      final content = _contentController.text.trim();
                      try {
                        await ExportService.instance.shareAsText(title: title, content: content);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    icon: Icon(
                      Icons.share_rounded,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    tooltip: 'Share Note',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (widget.onSave != null) {
                        widget.onSave!(
                          _titleController.text.trim(),
                          _contentController.text.trim(),
                          _selectedColor,
                          _tags,
                          _isPinned,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Colors & Tags Selector
          Row(
            children: [
              Text(
                'Color: ',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.lightText : AppColors.secondaryText,
                ),
              ),
              Row(
                children: _categoryColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.darkText,
                                width: 2.5,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 20),
              Text(
                'Tags: ',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.lightText : AppColors.secondaryText,
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ..._tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryPurple.withOpacity(0.25)
                            : AppColors.lightLavender,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryPurple.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _tags.remove(tag);
                              });
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  InkWell(
                    onTap: _showAddTagDialog,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF262636)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Tag',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rich Text Toolbar
          EditorToolbar(
            activeHeading: _activeHeading,
            isBold: _isBold,
            isItalic: _isItalic,
            isUnderline: _isUnderline,
            isStrikethrough: _isStrikethrough,
            isCode: _isCode,
            isBulletList: _isBulletList,
            isNumberedList: _isNumberedList,
            isChecklist: _isChecklist,
            onH1Tap: () => _applyHeading(1),
            onH2Tap: () => _applyHeading(2),
            onH3Tap: () => _applyHeading(3),
            onBulletListTap: _toggleBulletList,
            onNumberedListTap: _toggleNumberedList,
            onCheckboxTap: _toggleChecklist,
            onBoldTap: _toggleBold,
            onItalicTap: _toggleItalic,
            onUnderlineTap: _toggleUnderline,
            onStrikethroughTap: _toggleStrikethrough,
            onCodeTap: _toggleCode,
            onLinkTap: _insertLink,
            onImageTap: _insertImage,
            onTableTap: _insertTable,
            onBlockquoteTap: _insertBlockquote,
            onDividerTap: _insertDivider,
            onClearFormattingTap: _clearFormatting,
          ),
          const SizedBox(height: 16),

          // Title Row with Aligned Styled Pin Icon Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Note title...',
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                tooltip: _isPinned ? 'Unpin Note' : 'Pin Note',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isPinned
                        ? AppColors.primaryPurple.withOpacity(0.18)
                        : (isDark
                              ? const Color(0xFF1E1E2A)
                              : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isPinned
                          ? AppColors.primaryPurple.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    _isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    color: _isPinned ? AppColors.primaryPurple : hintColor,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isPinned = !_isPinned;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Borderless Editor Canvas
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                color: isDark ? AppColors.darkScaffoldBackground : Colors.white,
                child: Column(
                  children: [
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    onTap: _onTextFieldTap,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing your note here...',
                      hintStyle: TextStyle(color: hintColor, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // Editor Bottom Status Bar with Stats Pills
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFF0F0F3),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildStatBadge(
                            '📊 $_wordCount words',
                            isDark,
                            subtextColor,
                          ),
                          const SizedBox(width: 8),
                          _buildStatBadge(
                            '🔤 $_charCount chars',
                            isDark,
                            subtextColor,
                          ),
                          const SizedBox(width: 8),
                          _buildStatBadge(
                            '⏱️ $_readingTimeMinutes min read',
                            isDark,
                            subtextColor,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Tooltip(
                            message: 'Typography',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E2A)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Aa',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: subtextColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
          ),
        ],
      ),
    );
  }
}
