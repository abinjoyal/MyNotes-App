import 'package:flutter/material.dart';

class Folder {
  final String id;
  final String name;
  final Color color;
  final bool isLocked;

  const Folder({
    required this.id,
    required this.name,
    required this.color,
    this.isLocked = false,
  });
}
