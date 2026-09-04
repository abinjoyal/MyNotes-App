import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';

class TaskItem {
  final int index;
  final String text;
  final bool isCompleted;
  final String? tag;
  final String time;

  TaskItem({
    required this.index,
    required this.text,
    required this.isCompleted,
    this.tag,
    required this.time,
  });
}

class TasksChecklistView extends StatefulWidget {
  final Function(Note)? onNoteSelect;

  const TasksChecklistView({super.key, this.onNoteSelect});

  @override
  State<TasksChecklistView> createState() => _TasksChecklistViewState();
}

class _TasksChecklistViewState extends State<TasksChecklistView> {
  final NotesController _controller = NotesController.instance;
  final TextEditingController _newTaskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedNoteId;
  String _searchQuery = '';
  bool _isWorkspaceHidden = false;
  bool _isGridView = false;

  // Focus Timer State
  Timer? _focusTimer;
  int _timerTotalSeconds = 1500; // Default 25 min (Pomodoro)
  int _timerRemainingSeconds = 1500;
  bool _isTimerRunning = false;
  bool _showFocusTimerCard = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _controller.removeListener(_onNotesChanged);
    _newTaskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isTimerRunning) return;
    setState(() {
      _isTimerRunning = true;
      _showFocusTimerCard = true;
    });
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerRemainingSeconds > 0) {
        setState(() {
          _timerRemainingSeconds--;
        });
      } else {
        _stopTimer();
        _showTimerCompletedDialog();
      }
    });
  }

  void _pauseTimer() {
    _focusTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer([int? newSeconds]) {
    _focusTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      if (newSeconds != null) {
        _timerTotalSeconds = newSeconds;
      }
      _timerRemainingSeconds = _timerTotalSeconds;
    });
  }

  void _stopTimer() {
    _focusTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _timerRemainingSeconds = _timerTotalSeconds;
    });
  }

  String _formatTimerTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showTimerCompletedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: Color(0xFFFFB020), size: 28),
            SizedBox(width: 8),
            Text(
              'Focus Session Finished! 🎉',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Great job! You stayed focused and completed your timer session.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _showCustomTimerDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6B7280);
    final inputBg = isDark ? const Color(0xFF262636) : const Color(0xFFF3F4F6);
    final borderColor = isDark
        ? const Color(0xFF323246)
        : const Color(0xFFE5E7EB);

    final customController = TextEditingController(
      text: '${_timerTotalSeconds ~/ 60}',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: borderColor, width: 1),
              ),
              elevation: 16,
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            color: AppColors.primaryPurple,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Custom Focus Time',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Set your target focus duration in minutes.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    Text(
                      'DURATION (MINUTES)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subtextColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: customController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 10, 60, 90',
                          hintStyle: TextStyle(
                            color: subtextColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.access_time_filled_rounded,
                            color: AppColors.primaryPurple,
                            size: 20,
                          ),
                          suffixText: 'mins',
                          suffixStyle: TextStyle(
                            color: subtextColor,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'QUICK PRESETS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subtextColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [5, 10, 60, 90, 120].map((m) {
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              customController.text = '$m';
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2B2B3C)
                                  : const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF3B3B50)
                                    : const Color(0xFFC7D2FE),
                              ),
                            ),
                            child: Text(
                              '${m} min',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFD1D5DB)
                                    : AppColors.primaryPurple,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            foregroundColor: subtextColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            final mins = int.tryParse(
                              customController.text.trim(),
                            );
                            if (mins != null && mins > 0) {
                              Navigator.pop(ctx);
                              _resetTimer(mins * 60);
                            }
                          },
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Set Focus Timer',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFocusTimerCard(
    bool isDark,
    Color cardBg,
    Color textColor,
    Color borderColor,
    Color subtextColor,
  ) {
    final progress = _timerTotalSeconds > 0
        ? (_timerTotalSeconds - _timerRemainingSeconds) / _timerTotalSeconds
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E28) : const Color(0xFFF3F4F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isTimerRunning ? AppColors.primaryPurple : borderColor,
          width: _isTimerRunning ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Focus Timer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        _isTimerRunning
                            ? 'Focus session in progress...'
                            : 'Set a focus goal and work uninterrupted.',
                        style: TextStyle(fontSize: 12, color: subtextColor),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: subtextColor,
                    onPressed: () {
                      setState(() {
                        _showFocusTimerCard = false;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Presets Selection
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTimerPresetPill('15m', 900, isDark),
                    _buildTimerPresetPill('25m', 1500, isDark),
                    _buildTimerPresetPill('30m', 1800, isDark),
                    _buildTimerPresetPill('45m', 2700, isDark),
                    if (![900, 1500, 1800, 2700].contains(_timerTotalSeconds))
                      _buildTimerPresetPill(
                        '${_timerTotalSeconds ~/ 60}m',
                        _timerTotalSeconds,
                        isDark,
                      ),
                    ActionChip(
                      avatar: const Icon(
                        Icons.add_rounded,
                        size: 14,
                        color: AppColors.primaryPurple,
                      ),
                      label: const Text('Custom'),
                      onPressed: _isTimerRunning
                          ? null
                          : _showCustomTimerDialog,
                      backgroundColor: isDark
                          ? const Color(0xFF262632)
                          : const Color(0xFFEAEAEE),
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // Countdown Display & Progress Ring
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 5,
                          backgroundColor: isDark
                              ? const Color(0xFF2C2C38)
                              : const Color(0xFFE2E4EC),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isTimerRunning
                                ? const Color(0xFFFFB020)
                                : AppColors.primaryPurple,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimerTime(_timerRemainingSeconds),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Action Controls
                  ElevatedButton.icon(
                    onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                    icon: Icon(
                      _isTimerRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isTimerRunning ? 'Pause' : 'Start Focus',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTimerRunning
                          ? const Color(0xFFFF4081)
                          : AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _resetTimer(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPresetPill(String label, int seconds, bool isDark) {
    final isSelected = _timerTotalSeconds == seconds;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: _isTimerRunning
          ? null
          : (selected) {
              if (selected) {
                _resetTimer(seconds);
              }
            },
      selectedColor: AppColors.primaryPurple,
      backgroundColor: isDark
          ? const Color(0xFF262632)
          : const Color(0xFFEAEAEE),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
    );
  }

  void _onNotesChanged() {
    if (mounted) setState(() {});
  }

  List<Note> get _allChecklistNotes {
    final all = _controller.notes;
    final checklists = all.where((n) {
      final text = n.content;
      final matchesQuery =
          _searchQuery.isEmpty ||
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final isChecklist =
          text.contains('- [ ]') ||
          text.contains('- [x]') ||
          text.contains('- [X]') ||
          n.tags.any(
            (t) =>
                t.contains('task') ||
                t.contains('project') ||
                t.contains('daily'),
          );
      return matchesQuery && isChecklist;
    }).toList();

    return checklists;
  }

  Note? get _activeNote {
    final notes = _allChecklistNotes;
    if (notes.isEmpty) return null;
    if (_selectedNoteId != null) {
      try {
        return notes.firstWhere((n) => n.id == _selectedNoteId);
      } catch (_) {}
    }
    return notes.first;
  }

  List<TaskItem> _parseTasksFromContent(String content) {
    final lines = content.split('\n');
    final List<TaskItem> tasks = [];
    int idx = 0;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- [ ] ') ||
          trimmed.startsWith('- [x] ') ||
          trimmed.startsWith('- [X] ')) {
        final isDone =
            trimmed.startsWith('- [x] ') || trimmed.startsWith('- [X] ');
        String rawText = trimmed.substring(6).trim();

        String? tag;
        final tagMatch = RegExp(r'#(\w+)').firstMatch(rawText);
        if (tagMatch != null) {
          tag = tagMatch.group(1);
          rawText = rawText.replaceAll(RegExp(r'#\w+'), '').trim();
        }

        tasks.add(
          TaskItem(
            index: idx,
            text: rawText.isEmpty ? 'Untitled Task' : rawText,
            isCompleted: isDone,
            tag: tag,
            time: 'Today',
          ),
        );
      }
      idx++;
    }

    return tasks;
  }

  void _toggleTaskCompletion(Note note, TaskItem task) {
    final lines = note.content.split('\n');
    int matchIdx = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('- [ ] ') ||
          line.startsWith('- [x] ') ||
          line.startsWith('- [X] ')) {
        if (matchIdx == task.index) {
          final prefix = task.isCompleted ? '- [ ] ' : '- [x] ';
          final contentPart = line.substring(6);
          lines[i] = '$prefix$contentPart';
          break;
        }
        matchIdx++;
      }
    }

    _controller.saveNote(
      id: note.id,
      title: note.title,
      content: lines.join('\n'),
      indicatorColor: note.indicatorColor,
      tags: note.tags,
      isPinned: note.isPinned,
    );
  }

  void _addNewTask(Note note) {
    final text = _newTaskController.text.trim();
    if (text.isEmpty) return;

    final newContent = note.content.isEmpty
        ? '- [ ] $text'
        : '${note.content}\n- [ ] $text';

    _controller.saveNote(
      id: note.id,
      title: note.title,
      content: newContent,
      indicatorColor: note.indicatorColor,
      tags: note.tags,
      isPinned: note.isPinned,
    );

    _newTaskController.clear();
  }

  void _deleteTaskItem(Note note, TaskItem task) {
    final lines = note.content.split('\n');
    int matchIdx = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('- [ ] ') ||
          line.startsWith('- [x] ') ||
          line.startsWith('- [X] ')) {
        if (matchIdx == task.index) {
          lines.removeAt(i);
          break;
        }
        matchIdx++;
      }
    }

    _controller.saveNote(
      id: note.id,
      title: note.title,
      content: lines.join('\n'),
      indicatorColor: note.indicatorColor,
      tags: note.tags,
      isPinned: note.isPinned,
    );
  }

  void _createNewChecklistDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6B7280);
    final inputBg = isDark ? const Color(0xFF262636) : const Color(0xFFF3F4F6);
    final borderColor = isDark
        ? const Color(0xFF323246)
        : const Color(0xFFE5E7EB);

    final titleController = TextEditingController(text: 'New Task Checklist');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: borderColor, width: 1),
              ),
              elevation: 16,
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Icon Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.playlist_add_rounded,
                            color: AppColors.primaryPurple,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Task Checklist',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Organize your goals with a new checklist.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Input Field Label
                    Text(
                      'CHECKLIST TITLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subtextColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Styled Text Box
                    Container(
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: titleController,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Work Tasks, Daily Goals',
                          hintStyle: TextStyle(
                            color: subtextColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.edit_note_rounded,
                            color: AppColors.primaryPurple,
                            size: 22,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Title Suggestion Pills
                    Text(
                      'QUICK TEMPLATES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subtextColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            '📋 Daily Tasks',
                            '💼 Work Sprint',
                            '🎯 Weekly Goals',
                            '📚 Study List',
                          ].map((template) {
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  titleController.text = template.substring(3);
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2B2B3C)
                                      : const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF3B3B50)
                                        : const Color(0xFFC7D2FE),
                                  ),
                                ),
                                child: Text(
                                  template,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFD1D5DB)
                                        : AppColors.primaryPurple,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            foregroundColor: subtextColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            final title = titleController.text.trim();
                            if (title.isNotEmpty) {
                              Navigator.pop(ctx);
                              final newNote = Note(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                title: title,
                                content: '',
                                indicatorColor: const Color(0xFF00C853),
                                tags: ['#task'],
                                updatedAt: 'Just now',
                              );
                              _controller.saveNote(
                                id: newNote.id,
                                title: newNote.title,
                                content: newNote.content,
                                indicatorColor: newNote.indicatorColor,
                                tags: newNote.tags,
                              );
                              setState(() {
                                _selectedNoteId = newNote.id;
                                _isWorkspaceHidden = false;
                              });
                            }
                          },
                          //   icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                          label: const Text(
                            'Create Checklist',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('daily') ||
        lower.contains('morning') ||
        lower.contains('sun')) {
      return Icons.wb_sunny_outlined;
    } else if (lower.contains('work') ||
        lower.contains('office') ||
        lower.contains('job')) {
      return Icons.work_outline_rounded;
    } else if (lower.contains('study') ||
        lower.contains('learn') ||
        lower.contains('school')) {
      return Icons.school_outlined;
    } else if (lower.contains('home') ||
        lower.contains('house') ||
        lower.contains('chore')) {
      return Icons.home_outlined;
    } else if (lower.contains('fit') ||
        lower.contains('gym') ||
        lower.contains('workout')) {
      return Icons.fitness_center_rounded;
    } else if (lower.contains('shop') ||
        lower.contains('store') ||
        lower.contains('buy')) {
      return Icons.shopping_cart_outlined;
    }
    return Icons.check_box_outlined;
  }

  Color _getTagColor(String? tag) {
    if (tag == null) return AppColors.primaryPurple;
    final lower = tag.toLowerCase();
    if (lower == 'health') return const Color(0xFF00C853);
    if (lower == 'learning') return const Color(0xFF635BFF);
    if (lower == 'work') return const Color(0xFF4C6FFF);
    if (lower == 'personal') return const Color(0xFFFF4081);
    return AppColors.primaryPurple;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final subtextColor = isDark ? AppColors.lightText : const Color(0xFF6C757D);
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFEAEAEE);
    final inputBg = isDark ? const Color(0xFF262630) : const Color(0xFFF7F8FA);

    final checklistNotes = _allChecklistNotes;
    final activeNote = _activeNote;
    final activeTasks = activeNote != null
        ? _parseTasksFromContent(activeNote.content)
        : <TaskItem>[];

    final completedCount = activeTasks.where((t) => t.isCompleted).length;
    final totalCount = activeTasks.length;
    final progressVal = totalCount > 0 ? completedCount / totalCount : 0.0;
    final progressPct = (progressVal * 100).toInt();

    return Column(
      children: [
        // 1. Top Header Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00C853),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tasks Checklist',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightLavender,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${checklistNotes.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Search Input
                Container(
                  width: 200,
                  height: 38,
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: TextStyle(fontSize: 13, color: textColor),
                    decoration: const InputDecoration(
                      hintText: 'Search checklists or tasks...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8C98A9),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: Color(0xFF8C98A9),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // List / Grid View Toggle
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isGridView = false),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: !_isGridView
                                ? (isDark
                                      ? AppColors.primaryPurple.withOpacity(0.3)
                                      : AppColors.lightLavender)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.format_list_bulleted_rounded,
                            size: 18,
                            color: !_isGridView
                                ? AppColors.primaryPurple
                                : const Color(0xFF8C98A9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _isGridView = true),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _isGridView
                                ? (isDark
                                      ? AppColors.primaryPurple.withOpacity(0.3)
                                      : AppColors.lightLavender)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 18,
                            color: _isGridView
                                ? AppColors.primaryPurple
                                : const Color(0xFF8C98A9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showFocusTimerCard = !_showFocusTimerCard;
                    });
                  },
                  icon: Icon(
                    _isTimerRunning
                        ? Icons.timer_rounded
                        : (_showFocusTimerCard
                              ? Icons.timer_rounded
                              : Icons.timer_outlined),
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isTimerRunning
                        ? '⏱️ ${_formatTimerTime(_timerRemainingSeconds)}'
                        : 'Focus Timer',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTimerRunning
                        ? const Color(0xFFFFB020)
                        : (_showFocusTimerCard
                              ? const Color(0xFF635BFF)
                              : const Color(0xFF2C2C38)),
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
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _createNewChecklistDialog,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Create Task Checklist',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
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

        // Optional Focus Timer Banner Card
        if (_showFocusTimerCard || _isTimerRunning)
          _buildFocusTimerCard(
            isDark,
            cardBg,
            textColor,
            borderColor,
            subtextColor,
          ),

        // 2. Main 2-Column Split Workspace View
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT PANEL: "My Checklists" List / Grid
              _isWorkspaceHidden
                  ? Expanded(
                      child: _buildMyChecklistsContainer(
                        cardBg,
                        borderColor,
                        textColor,
                        subtextColor,
                        isDark,
                        checklistNotes,
                        activeNote,
                      ),
                    )
                  : SizedBox(
                      width: 280,
                      child: _buildMyChecklistsContainer(
                        cardBg,
                        borderColor,
                        textColor,
                        subtextColor,
                        isDark,
                        checklistNotes,
                        activeNote,
                      ),
                    ),

              if (!_isWorkspaceHidden) const SizedBox(width: 16),

              // RIGHT WORKSPACE PANEL: Active Checklist Detail Workspace
              if (!_isWorkspaceHidden)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: activeNote == null
                        ? Center(
                            child: Text(
                              'Select or create a checklist to get started',
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Active Header with Close (X) button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryPurple
                                              .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(activeNote.title),
                                          size: 26,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activeNote.title,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Stay productive and get things done.',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: subtextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          if (widget.onNoteSelect != null) {
                                            widget.onNoteSelect!(activeNote);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                        ),
                                        label: const Text('Edit'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: textColor,
                                          side: BorderSide(color: borderColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Close (X) Button to Hide Workspace Panel
                                      IconButton(
                                        tooltip: 'Close Workspace Panel',
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 22,
                                        ),
                                        color: isDark
                                            ? AppColors.lightText
                                            : const Color(0xFF6C757D),
                                        onPressed: () {
                                          setState(() {
                                            _isWorkspaceHidden = true;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Progress Indicator Bar
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$totalCount tasks • $completedCount completed',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: subtextColor,
                                    ),
                                  ),
                                  Text(
                                    '$progressPct%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryPurple,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progressVal,
                                  minHeight: 8,
                                  backgroundColor: isDark
                                      ? const Color(0xFF2C2C35)
                                      : const Color(0xFFEEECFF),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryPurple,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Quick Add Task Bar
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: inputBg,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: TextField(
                                        controller: _newTaskController,
                                        onSubmitted: (_) =>
                                            _addNewTask(activeNote),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'O  Add a new task...',
                                          hintStyle: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF8C98A9),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _addNewTask(activeNote),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Task Items List
                              Expanded(
                                child: activeTasks.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No tasks added yet. Type above to add your first task!',
                                          style: TextStyle(
                                            color: subtextColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: activeTasks.length,
                                        itemBuilder: (context, index) {
                                          final task = activeTasks[index];
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1E1E26)
                                                  : const Color(0xFFF9FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: borderColor,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _toggleTaskCompletion(
                                                        activeNote,
                                                        task,
                                                      ),
                                                  child: Icon(
                                                    task.isCompleted
                                                        ? Icons
                                                              .check_box_rounded
                                                        : Icons
                                                              .check_box_outline_blank_rounded,
                                                    color: task.isCompleted
                                                        ? AppColors
                                                              .primaryPurple
                                                        : const Color(
                                                            0xFF8C98A9,
                                                          ),
                                                    size: 22,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    task.text,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: task.isCompleted
                                                          ? subtextColor
                                                          : textColor,
                                                      decoration:
                                                          task.isCompleted
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : TextDecoration.none,
                                                    ),
                                                  ),
                                                ),
                                                if (task.tag != null) ...[
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _getTagColor(
                                                        task.tag,
                                                      ).withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      task.tag!,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: _getTagColor(
                                                          task.tag,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                ],
                                                Text(
                                                  task.time,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: subtextColor,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.close_rounded,
                                                    size: 16,
                                                    color: Color(0xFF8C98A9),
                                                  ),
                                                  onPressed: () =>
                                                      _deleteTaskItem(
                                                        activeNote,
                                                        task,
                                                      ),
                                                  tooltip: 'Delete task',
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
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyChecklistsContainer(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subtextColor,
    bool isDark,
    List<Note> checklistNotes,
    Note? activeNote,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'My Checklists',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (_isWorkspaceHidden) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightLavender,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Full View',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                icon: Icon(Icons.add_rounded, size: 20, color: textColor),
                onPressed: _createNewChecklistDialog,
                tooltip: 'Add New Checklist',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: checklistNotes.isEmpty
                ? Center(
                    child: Text(
                      'No Checklists Created',
                      style: TextStyle(color: subtextColor, fontSize: 13),
                    ),
                  )
                : (_isGridView
                      ? GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: _isWorkspaceHidden
                                    ? 260
                                    : 250,
                                mainAxisExtent: 88,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: checklistNotes.length,
                          itemBuilder: (context, index) {
                            final note = checklistNotes[index];
                            final isSelected =
                                !_isWorkspaceHidden &&
                                activeNote?.id == note.id;
                            final tasks = _parseTasksFromContent(note.content);
                            final done = tasks
                                .where((t) => t.isCompleted)
                                .length;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedNoteId = note.id;
                                  _isWorkspaceHidden = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                            ? AppColors.primaryPurple
                                                  .withOpacity(0.2)
                                            : AppColors.lightLavender
                                                  .withOpacity(0.7))
                                      : (isDark
                                            ? const Color(0xFF1E1E26)
                                            : const Color(0xFFF9FAFC)),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryPurple
                                        : borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF262630)
                                            : const Color(0xFFF1F3F6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(note.title),
                                        size: 20,
                                        color: isSelected
                                            ? AppColors.primaryPurple
                                            : subtextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            note.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isSelected
                                                  ? AppColors.primaryPurple
                                                  : textColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${tasks.length} tasks • $done completed',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: subtextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: checklistNotes.length,
                          itemBuilder: (context, index) {
                            final note = checklistNotes[index];
                            final isSelected =
                                !_isWorkspaceHidden &&
                                activeNote?.id == note.id;
                            final tasks = _parseTasksFromContent(note.content);
                            final done = tasks
                                .where((t) => t.isCompleted)
                                .length;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.primaryPurple.withOpacity(
                                              0.2,
                                            )
                                          : AppColors.lightLavender.withOpacity(
                                              0.7,
                                            ))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : Colors.transparent,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF262630)
                                        : const Color(0xFFF1F3F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(note.title),
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.primaryPurple
                                        : subtextColor,
                                  ),
                                ),
                                title: Text(
                                  note.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.primaryPurple
                                        : textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${tasks.length} tasks • $done completed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtextColor,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedNoteId = note.id;
                                    _isWorkspaceHidden = false;
                                  });
                                },
                              ),
                            );
                          },
                        )),
          ),
        ],
      ),
    );
  }
}
