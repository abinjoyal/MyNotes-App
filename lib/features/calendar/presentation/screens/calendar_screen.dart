import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/controllers/notes_provider.dart';
import '../../../settings/controllers/settings_controller.dart';
import '../controllers/calendar_provider.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/calendar_view_widget.dart';
import '../widgets/calendar_day_notes_list.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final Function(Note)? onNoteSelect;

  const CalendarScreen({super.key, this.onNoteSelect});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late bool _isGridView;
  final SettingsController _settingsController = SettingsController.instance;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final calendarController = ref.watch(calendarControllerProvider);
    final notesController = ref.watch(notesProvider);

    final notesList = notesController.notes;
    final selectedDay = calendarController.selectedDay;
    final focusedDay = calendarController.focusedDay;
    final format = calendarController.calendarFormat;

    final selectedNotes = calendarController.getEventsForDay(
      selectedDay,
      notesList,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;

    return Scaffold(
      backgroundColor: context.appColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarHeaderWidget(
                isDark: isDark,
                textColor: textColor,
                calendarFormat: format,
                onFormatChanged: (newFormat) {
                  calendarController.setCalendarFormat(newFormat);
                },
                onTodayTap: () {
                  calendarController.jumpToToday();
                },
              ),
              const SizedBox(height: 16),
              CalendarViewWidget(
                focusedDay: focusedDay,
                selectedDay: selectedDay,
                calendarFormat: format,
                allNotes: notesList,
                eventLoader: calendarController.getEventsForDay,
                onDaySelected: (sel, foc) {
                  calendarController.setSelectedDay(sel, foc);
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: CalendarDayNotesList(
                  selectedDate: selectedDay,
                  selectedNotes: selectedNotes,
                  isGridView: _isGridView,
                  onNoteSelect: widget.onNoteSelect,
                  onAddNoteForDate: widget.onNoteSelect != null
                      ? () {
                          final newNote = notesController.createTemplateNote(
                            'blank',
                          );
                          widget.onNoteSelect!(newNote);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
