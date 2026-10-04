extension DateTimeExtensions on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins min ago';
    } else if (difference.inHours < 24) {
      final hrs = difference.inHours;
      return '$hrs ${hrs == 1 ? "hour" : "hours"} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return '$days ${days == 1 ? "day" : "days"} ago';
    } else {
      return formattedDate;
    }
  }

  String get formattedTime {
    final hour = this.hour % 12 == 0 ? 12 : this.hour % 12;
    final minute = this.minute.toString().padLeft(2, '0');
    final ampm = this.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[this.month - 1];
    return '$month $day, $year';
  }
}

String formatRelativeTime(String rawDate) {
  if (rawDate.isEmpty || rawDate == 'Draft') return 'Draft';

  DateTime? parsed = DateTime.tryParse(rawDate);

  if (parsed == null && RegExp(r'^\d+$').hasMatch(rawDate)) {
    final ms = int.tryParse(rawDate);
    if (ms != null) {
      parsed = DateTime.fromMillisecondsSinceEpoch(ms);
    }
  }

  if (parsed == null) {
    if (rawDate.toLowerCase().contains('just now')) {
      return 'Just now';
    }
    return rawDate;
  }

  return parsed.timeAgo;
}
