import 'package:flutter/material.dart';
import '../../../notes/domain/entities/note.dart';

class CalendarEventMarker extends StatelessWidget {
  final List<Note> events;

  const CalendarEventMarker({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    // Show up to 3 colored dots based on note indicator colors
    final displayEvents = events.take(3).toList();

    return Positioned(
      bottom: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: displayEvents.map((note) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: note.indicatorColor,
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }
}
