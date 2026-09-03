import 'package:flutter/material.dart';
import 'constants/app_strings.dart';
import 'layout/desktop_layout.dart';
import 'layout/responsive_layout.dart';
import 'theme/app_theme.dart';

class MyNotesApp extends StatelessWidget {
  const MyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const ResponsiveLayout(
        mobile: Scaffold(
          body: Center(
            child: Text('MyNotes Mobile View'),
          ),
        ),
        desktop: DesktopLayout(),
      ),
    );
  }
}
