import 'package:flutter/material.dart';

// Mobile Responsive Calculations (Figma Frame: 375 x 812)
double getHeight(BuildContext context, double figmaHeight) {
  final screenHeight = MediaQuery.of(context).size.height;
  const figmaScreenHeight = 812; // Figma frame height
  return screenHeight * (figmaHeight / figmaScreenHeight);
}

double getWidth(BuildContext context, double figmaWidth) {
  final screenWidth = MediaQuery.of(context).size.width;
  const figmaScreenWidth = 375; // Figma frame width
  return screenWidth * (figmaWidth / figmaScreenWidth);
}

// Desktop Responsive Calculations (Figma Frame: 1440 x 900)
double getDesktopHeight(BuildContext context, double figmaHeight) {
  final screenHeight = MediaQuery.of(context).size.height;
  const figmaDesktopHeight = 900; // Figma desktop frame height
  return screenHeight * (figmaHeight / figmaDesktopHeight);
}

double getDesktopWidth(BuildContext context, double figmaWidth) {
  final screenWidth = MediaQuery.of(context).size.width;
  const figmaDesktopWidth = 1440; // Figma desktop frame width
  return screenWidth * (figmaWidth / figmaDesktopWidth);
}

// Responsive Layout Builder Widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= 1100) {
      return desktop;
    } else if (width >= 600 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
