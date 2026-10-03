import 'package:flutter_riverpod/legacy.dart';
import 'calendar_controller.dart';

final calendarControllerProvider = ChangeNotifierProvider<CalendarController>((
  ref,
) {
  return CalendarController();
});
