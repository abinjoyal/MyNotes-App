import 'package:flutter/material.dart';

abstract class AppColors {
  // Main Brand Colors
  /// Primary Purple - #635BFF
  static const Color primaryPurple = Color(0xFF635BFF);

  /// Light Lavender - #EEECFF
  static const Color lightLavender = Color(0xFFEEECFF);

  /// Soft Gray - #F1F3F6
  static const Color softGray = Color(0xFFF1F3F6);

  /// Dark Text - #17191C
  static const Color darkText = Color(0xFF17191C);

  // Text Colors
  static const Color secondaryText = Color(0xFF6C757D);
  static const Color lightText = Color(0xFF98A2B3);

  // Surface & Layout Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color sidebarBackground = Color(0xFFF8F9FA);
  static const Color divider = Color(0xFFE9ECEF);
  static const Color border = Color(0xFFE0E0E0);

  // Dark Theme Surface Colors
  static const Color darkScaffoldBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
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

