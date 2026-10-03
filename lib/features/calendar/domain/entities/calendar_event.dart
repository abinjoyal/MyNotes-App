import 'package:flutter/material.dart';
import '../../../notes/domain/entities/note.dart';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final Color color;
  final Note note;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.color,
    required this.note,
  });
}
