import 'package:flutter/material.dart';

abstract class AppSizes {
  // Padding & Margins
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;

  // Border Radius
  static const double r4 = 4.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;

  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Layout & Component Sizes
  static const double sidebarWidth = 260.0;
  static const double sidebarCollapsedWidth = 72.0;
  static const double appBarHeight = 64.0;
  static const double fabSize = 56.0;
  static const double noteCardMinHeight = 120.0;
  static const double noteCardMaxHeight = 280.0;

  // SizedBox Spacing Helpers (Height)
  static const gapH4 = SizedBox(height: p4);
  static const gapH8 = SizedBox(height: p8);
  static const gapH12 = SizedBox(height: p12);
  static const gapH16 = SizedBox(height: p16);
  static const gapH20 = SizedBox(height: p20);
  static const gapH24 = SizedBox(height: p24);
  static const gapH32 = SizedBox(height: p32);

  // SizedBox Spacing Helpers (Width)
  static const gapW4 = SizedBox(width: p4);
  static const gapW8 = SizedBox(width: p8);
  static const gapW12 = SizedBox(width: p12);
  static const gapW16 = SizedBox(width: p16);
  static const gapW20 = SizedBox(width: p20);
  static const gapW24 = SizedBox(width: p24);
  static const gapW32 = SizedBox(width: p32);
}
