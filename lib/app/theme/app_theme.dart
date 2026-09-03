import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

abstract class AppTheme {
  static ThemeData get light => lightThemeData;
  static ThemeData get dark => darkThemeData;
}
