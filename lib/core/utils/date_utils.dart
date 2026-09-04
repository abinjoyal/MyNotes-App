abstract class AppDateUtils {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Formats date to full string e.g. "Sep 4, 2026 at 9:43 PM"
  static String formatFullDateTime(DateTime dt) {
    final month = _months[dt.month - 1];
    final day = dt.day;
    final year = dt.year;
    final timeStr = formatTimeOnly(dt);
    return '$month $day, $year at $timeStr';
  }

  /// Formats date to short date string e.g. "04/09/2026"
  static String formatShortDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    return '$day/$month/$year';
  }

  /// Formats time e.g. "9:43 PM"
  static String formatTimeOnly(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
