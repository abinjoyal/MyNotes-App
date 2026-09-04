import 'package:flutter/material.dart';
import 'constants/app_strings.dart';
import 'theme/app_theme.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

class MyNotesApp extends StatefulWidget {
  const MyNotesApp({super.key});

  @override
  State<MyNotesApp> createState() => _MyNotesAppState();
}

class _MyNotesAppState extends State<MyNotesApp> {
  final SettingsController _settingsController = SettingsController.instance;

  @override
  void initState() {
    super.initState();
    _settingsController.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settingsController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _settingsController.themeMode,
      home: const SplashScreen(),
    );
  }
}
