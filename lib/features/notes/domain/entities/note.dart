import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final Color indicatorColor;
  final List<String> tags;
  final String updatedAt;
  final bool isPinned;
  final String? folderName;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.indicatorColor,
    required this.tags,
    required this.updatedAt,
    this.isPinned = false,
    this.folderName,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    Color? indicatorColor,
    List<String>? tags,
    String? updatedAt,
    bool? isPinned,
    String? folderName,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      folderName: folderName ?? this.folderName,
    );
  }
}
