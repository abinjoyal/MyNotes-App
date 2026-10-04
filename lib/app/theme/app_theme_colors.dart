import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppThemeColors {
  final bool isDark;
  final Color scaffoldBg;
  final Color cardBg;
  final Color textColor;
  final Color borderColor;
  final Color secondaryTextColor;
  final Color dropdownBg;

  const AppThemeColors._({
    required this.isDark,
    required this.scaffoldBg,
    required this.cardBg,
    required this.textColor,
    required this.borderColor,
    required this.secondaryTextColor,
    required this.dropdownBg,
  });

  factory AppThemeColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppThemeColors._(
      isDark: isDark,
      scaffoldBg: isDark
          ? AppColors.darkScaffoldBackground
          : AppColors.softGray,
      cardBg: isDark ? AppColors.darkSurface : AppColors.cardBackground,
      textColor: isDark ? AppColors.darkTextPrimary : AppColors.darkText,
      borderColor: isDark ? AppColors.darkBorder : AppColors.border,
      secondaryTextColor: isDark
          ? const Color(0xFF98A2B3)
          : AppColors.secondaryText,
      dropdownBg: isDark ? const Color(0xFF2A2A30) : AppColors.selectedBackground,
    );
  }
}

extension AppThemeExtension on BuildContext {
  AppThemeColors get appColors => AppThemeColors.of(this);
}
