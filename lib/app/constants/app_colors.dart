import 'package:flutter/material.dart';

abstract class AppColors {
  // Main Brand Colors (Warm Terracotta Theme)
  /// Primary - #8B5E3C
  static const Color primaryPurple = Color(0xFF8B5E3C);

  /// Accent - #C08457
  static const Color primaryPink = Color(0xFFC08457);

  /// Selected / Soft Highlight - #E9D8C3
  static const Color lightLavender = Color(0xFFE9D8C3);

  /// Background - #FAF7F2
  static const Color softGray = Color(0xFFFAF7F2);

  /// Dark Text - #29231E
  static const Color darkText = Color(0xFF29231E);

  // Text Colors
  static const Color secondaryText = Color(0xFF81766B);
  static const Color lightText = secondaryText;

  // Surface & Layout Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF1EADF);
  static const Color sidebarBackground = cardBackground;
  static const Color selectedBackground = lightLavender;
  static const Color divider = Color(0xFFE4D9CB);
  static const Color border = divider;

  // Dark Theme Surface Colors
  static const Color darkScaffoldBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSidebarBackground = Color(0xFF241B16);
  static const Color darkBorder = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);

  // Note Card Colors (Pastels suitable for note tiles)
  static const Color noteYellow = Color(0xFFFFF3C4);
  static const Color noteGreen = Color(0xFFD1E7DD);
  static const Color noteBlue = Color(0xFFCFF4FC);
  static const Color notePurple = Color(0xFFE2D9F3);
  static const Color notePink = Color(0xFFF8D7DA);
  static const Color noteOrange = Color(0xFFFFE5D9);
  static const Color noteTeal = Color(0xFFD2F4EA);

  // Status & Accent Colors
  static const Color success = Color(0xFF198754);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF0D6EFD);

  /// List of note card colors for random or user selection
  static const List<Color> noteCardColors = [
    noteYellow,
    noteGreen,
    noteBlue,
    notePurple,
    notePink,
    noteOrange,
    noteTeal,
  ];
}
