import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final Color indicatorColor;
  final List<String> tags;
  final String updatedAt;
  final bool isPinned;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.indicatorColor,
    required this.tags,
    required this.updatedAt,
    this.isPinned = false,
  });
}
