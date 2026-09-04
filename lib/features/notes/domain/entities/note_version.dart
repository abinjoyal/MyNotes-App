import 'package:flutter/material.dart';

class NoteVersionSnapshot {
  final String id;
  final String noteId;
  final String title;
  final String content;
  final Color indicatorColor;
  final List<String> tags;
  final String timestamp;
  final int wordCount;
  final int charCount;

  const NoteVersionSnapshot({
    required this.id,
    required this.noteId,
    required this.title,
    required this.content,
    required this.indicatorColor,
    required this.tags,
    required this.timestamp,
    required this.wordCount,
    required this.charCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noteId': noteId,
      'title': title,
      'content': content,
      'colorValue': indicatorColor.value,
      'tags': tags,
      'timestamp': timestamp,
      'wordCount': wordCount,
      'charCount': charCount,
    };
  }

  factory NoteVersionSnapshot.fromMap(Map<String, dynamic> map) {
    return NoteVersionSnapshot(
      id: map['id'] ?? '',
      noteId: map['noteId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      indicatorColor: Color(map['colorValue'] ?? 0xFF635BFF),
      tags: List<String>.from(map['tags'] ?? []),
      timestamp: map['timestamp'] ?? '',
      wordCount: map['wordCount'] ?? 0,
      charCount: map['charCount'] ?? 0,
    );
  }
}
