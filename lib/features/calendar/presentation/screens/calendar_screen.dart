import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/controllers/notes_provider.dart';
import '../../../notes/presentation/widgets/note_list.dart';
import '../../../settings/controllers/settings_controller.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final Function(Note)? onNoteSelect;

  const CalendarScreen({
    super.key,
    this.onNoteSelect,
  });

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late bool _isGridView;
  final SettingsController _settingsController = SettingsController.instance;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _isGridView = _settingsController.isGridView;
    _settingsController.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settingsController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        _isGridView = _settingsController.isGridView;
      });
    }
  }

  DateTime? _parseNoteDate(Note note) {
    try {
      final ms = int.tryParse(note.id);
      if (ms != null) {
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    } catch (_) {}
    return null;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Note> _getEventsForDay(DateTime day, List<Note> allNotes) {
    return allNotes.where((note) {
      final date = _parseNoteDate(note);
      return _isSameDay(date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(notesProvider);
    final notesList = controller.notes;
    
    final selectedNotes = _getEventsForDay(_selectedDay ?? _focusedDay, notesList);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final calendarBgColor = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [const Color(0xFF1A1A24), const Color(0xFF121212)]
              : [const Color(0xFFF8F9FF), const Color(0xFFF1F3F6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📅 Calendar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View your notes by date.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF8C98A9) : const Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: calendarBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAEAEE),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TableCalendar<Note>(
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: (day) => _getEventsForDay(day, notesList),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              bottom: 6,
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPink,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(color: textColor),
                        weekendTextStyle: TextStyle(color: textColor.withOpacity(0.7)),
                        outsideTextStyle: TextStyle(color: textColor.withOpacity(0.3)),
                      ),
                      headerStyle: HeaderStyle(
                        titleTextStyle: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                        rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: textColor),
                        weekendStyle: TextStyle(color: textColor.withOpacity(0.7)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Notes for ${DateFormat.yMMMd().format(_selectedDay ?? _focusedDay)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: selectedNotes.isEmpty
                      ? Center(
                          child: Text(
                            'No notes for this date',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF8C98A9) : const Color(0xFF6C757D),
                            ),
                          ),
                        )
                      : NoteList(
                          notes: selectedNotes,
                          isGridView: _isGridView,
                          activeRoute: 'all_notes',
                          onNoteSelect: widget.onNoteSelect,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
