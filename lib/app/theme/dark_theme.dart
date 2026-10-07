import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

ThemeData get darkThemeData => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryPurple,
  scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryPurple,
    secondary: AppColors.lightLavender.withValues(alpha: 0.2),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    error: AppColors.error,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    titleTextStyle: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.r12),
      side: const BorderSide(color: AppColors.darkBorder, width: 1),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurface,
    hintStyle: const TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.normal,
      color: Color(0xFF98A2B3),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSizes.p16,
      vertical: AppSizes.p12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.r12),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.r12),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.r12),
      borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryPurple,
    foregroundColor: AppColors.white,
    elevation: 2,
  ),
);
