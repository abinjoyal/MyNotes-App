import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/features/tasks/utils/task_markdown_utils.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/controllers/notes_provider.dart';
import '../../domain/entities/task.dart';
import '../controllers/focus_timer_controller.dart';
import 'create_checklist_dialog.dart';
import 'custom_timer_dialog.dart';
import 'tasks_detail_workspace.dart';
import 'tasks_focus_timer_card.dart';
import 'tasks_header_bar.dart';
import 'tasks_sidebar_container.dart';

class TasksChecklistView extends ConsumerStatefulWidget {
  final Function(Note)? onNoteSelect;

  const TasksChecklistView({super.key, this.onNoteSelect});

  @override
  ConsumerState<TasksChecklistView> createState() => _TasksChecklistViewState();
}

class _TasksChecklistViewState extends ConsumerState<TasksChecklistView> {
  final TextEditingController _newTaskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedNoteId;
  String _searchQuery = '';
  bool _isWorkspaceHidden = false;
  bool _isGridView = false;

  @override
  void dispose() {
    _newTaskController.dispose();
    _searchController.dispose();
    super.dispose();
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

  void _showCustomTimerDialog(FocusTimerController timerController) {
    showDialog(
      context: context,
      builder: (ctx) => CustomTimerDialog(
        initialMinutes: timerController.totalSeconds ~/ 60,
        onTimerSet: (seconds) => timerController.resetTimer(seconds),
      ),
    );
  }

  void _createNewChecklistDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CreateChecklistDialog(
        onCreate: (title) {
          final newNote = Note(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            content: '',
            indicatorColor: const Color(0xFF00C853),
            tags: ['#task'],
            updatedAt: 'Just now',
          );
          ref
              .read(notesProvider)
              .saveNote(
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
        },
      ),
    );
  }

  List<Note> get _allChecklistNotes {
    final controller = ref.watch(notesProvider);
    final all = controller.notes;
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

  void _toggleTaskCompletion(Note note, TaskItem task) {
    final updatedContent = TaskMarkdownUtils.toggleTaskInContent(
      note.content,
      task.index,
      task.isCompleted,
    );

    ref
        .read(notesProvider)
        .saveNote(
          id: note.id,
          title: note.title,
          content: updatedContent,
          indicatorColor: note.indicatorColor,
          tags: note.tags,
          isPinned: note.isPinned,
        );
  }

  void _addNewTask(Note note) {
    final text = _newTaskController.text.trim();
    if (text.isEmpty) return;

    final updatedContent = TaskMarkdownUtils.addNewTaskToContent(
      note.content,
      text,
    );

    ref
        .read(notesProvider)
        .saveNote(
          id: note.id,
          title: note.title,
          content: updatedContent,
          indicatorColor: note.indicatorColor,
          tags: note.tags,
          isPinned: note.isPinned,
        );

    _newTaskController.clear();
  }

  void _deleteTaskItem(Note note, TaskItem task) {
    final updatedContent = TaskMarkdownUtils.deleteTaskFromContent(
      note.content,
      task.index,
    );

    ref
        .read(notesProvider)
        .saveNote(
          id: note.id,
          title: note.title,
          content: updatedContent,
          indicatorColor: note.indicatorColor,
          tags: note.tags,
          isPinned: note.isPinned,
        );
  }

  @override
  Widget build(BuildContext context) {
    final timerController = ref.watch(focusTimerProvider);
    final checklistNotes = _allChecklistNotes;
    final activeNote = _activeNote;
    final activeTasks = activeNote != null
        ? TaskMarkdownUtils.parseTasksFromContent(activeNote.content)
        : <TaskItem>[];

    return Column(
      children: [
        // 1. Top Header Bar
        TasksHeaderBar(
          totalChecklistsCount: checklistNotes.length,
          searchController: _searchController,
          searchQuery: _searchQuery,
          onSearchChanged: (val) => setState(() => _searchQuery = val),
          isGridView: _isGridView,
          onToggleViewMode: (grid) => setState(() => _isGridView = grid),
          isTimerRunning: timerController.isRunning,
          showFocusTimerCard: timerController.showCard,
          timerRemainingSeconds: timerController.remainingSeconds,
          onToggleFocusTimer: timerController.toggleCardVisibility,
          onCreateChecklist: _createNewChecklistDialog,
          formatTimerTime: (_) => timerController.formattedTime,
        ),
        const SizedBox(height: 16),

        // 2. Optional Focus Timer Banner Card
        if (timerController.showCard || timerController.isRunning)
          TasksFocusTimerCard(
            timerTotalSeconds: timerController.totalSeconds,
            timerRemainingSeconds: timerController.remainingSeconds,
            isTimerRunning: timerController.isRunning,
            onStartTimer: () =>
                timerController.startTimer(_showTimerCompletedDialog),
            onPauseTimer: timerController.pauseTimer,
            onResetTimer: timerController.resetTimer,
            onCloseCard: timerController.hideCard,
            onCustomTimerTap: () => _showCustomTimerDialog(timerController),
            formatTime: (_) => timerController.formattedTime,
          ),

        // 3. Main Split Workspace View
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT PANEL: "My Checklists" List / Grid
              _isWorkspaceHidden
                  ? Expanded(
                      child: TasksSidebarContainer(
                        checklistNotes: checklistNotes,
                        activeNote: activeNote,
                        isWorkspaceHidden: _isWorkspaceHidden,
                        isGridView: _isGridView,
                        onSelectNote: (id) => setState(() {
                          _selectedNoteId = id;
                          _isWorkspaceHidden = false;
                        }),
                        onCreateChecklist: _createNewChecklistDialog,
                        parseTasksFromContent:
                            TaskMarkdownUtils.parseTasksFromContent,
                        getCategoryIcon: TaskMarkdownUtils.getCategoryIcon,
                      ),
                    )
                  : SizedBox(
                      width: 280,
                      child: TasksSidebarContainer(
                        checklistNotes: checklistNotes,
                        activeNote: activeNote,
                        isWorkspaceHidden: _isWorkspaceHidden,
                        isGridView: _isGridView,
                        onSelectNote: (id) => setState(() {
                          _selectedNoteId = id;
                          _isWorkspaceHidden = false;
                        }),
                        onCreateChecklist: _createNewChecklistDialog,
                        parseTasksFromContent:
                            TaskMarkdownUtils.parseTasksFromContent,
                        getCategoryIcon: TaskMarkdownUtils.getCategoryIcon,
                      ),
                    ),

              if (!_isWorkspaceHidden) const SizedBox(width: 16),

              // RIGHT PANEL: Active Checklist Detail Workspace
              if (!_isWorkspaceHidden)
                Expanded(
                  child: TasksDetailWorkspace(
                    activeNote: activeNote,
                    activeTasks: activeTasks,
                    newTaskController: _newTaskController,
                    onCloseWorkspace: () =>
                        setState(() => _isWorkspaceHidden = true),
                    onNoteEditSelect: widget.onNoteSelect,
                    onToggleTaskCompletion: _toggleTaskCompletion,
                    onDeleteTaskItem: _deleteTaskItem,
                    onAddNewTask: _addNewTask,
                    getCategoryIcon: TaskMarkdownUtils.getCategoryIcon,
                    getTagColor: TaskMarkdownUtils.getTagColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
