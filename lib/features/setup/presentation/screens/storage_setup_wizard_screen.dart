import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/layout/desktop_layout.dart';
import '../../../../app/layout/responsive_layout.dart';
import '../../../../core/services/storage_location_service.dart';
import '../../../pin/presentation/screens/passcode_lock_screen.dart';
import '../../../settings/controllers/settings_controller.dart';

class StorageSetupWizardScreen extends StatefulWidget {
  const StorageSetupWizardScreen({super.key});

  @override
  State<StorageSetupWizardScreen> createState() =>
      _StorageSetupWizardScreenState();
}

class _StorageSetupWizardScreenState extends State<StorageSetupWizardScreen> {
  String _selectedPath = '';
  String _defaultPath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPaths();
  }

  Future<void> _initPaths() async {
    final defaultDir = await StorageLocationService.instance
        .getDefaultStoragePath();
    if (!mounted) return;
    setState(() {
      _defaultPath = defaultDir;
      _selectedPath = defaultDir;
      _isLoading = false;
    });
  }

  Future<void> _pickCustomFolder() async {
    try {
      String? initialDir = _selectedPath;
      if (initialDir.isNotEmpty && !Directory(initialDir).existsSync()) {
        final parentDir = Directory(initialDir).parent;
        initialDir = parentDir.existsSync() ? parentDir.path : null;
      }

      final String? selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select Storage Folder for MyNotes',
        initialDirectory: initialDir,
      );

      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        setState(() {
          _selectedPath = StorageLocationService.instance
              .ensureMyNotesSubfolder(selectedDirectory);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open folder picker: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _useDefaultFolder() {
    setState(() {
      _selectedPath = _defaultPath;
    });
  }

  Future<void> _onContinue() async {
    if (_selectedPath.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    await StorageLocationService.instance.completeSetup(_selectedPath);

    if (!mounted) return;

    final settings = SettingsController.instance;
    final Widget targetScreen = settings.enablePinLock
        ? PasscodeLockScreen(
            isSetupMode: false,
            onSuccess: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ResponsiveLayout(
                    mobile: Scaffold(
                      body: Center(child: Text('MyNotes Mobile View')),
                    ),
                    desktop: DesktopLayout(),
                  ),
                ),
              );
            },
          )
        : const ResponsiveLayout(
            mobile: Scaffold(body: Center(child: Text('MyNotes Mobile View'))),
            desktop: DesktopLayout(),
          );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkScaffoldBackground
          : AppColors.softGray,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: isDark ? AppColors.darkSurface : AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryPurple, Color(0xFF8B85FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.folder_special_rounded,
                        size: 48,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title & Subtitle
                    Text(
                      'Welcome to MyNotes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your notes. Your storage.\nYou decide where they live.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.lightText
                            : AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Selected Directory Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : AppColors.softGray,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.folder_open_rounded,
                                color: AppColors.primaryPurple,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Storage Location',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _selectedPath.isEmpty
                                ? 'Loading storage location...'
                                : _selectedPath,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.lightText
                                  : AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Notes will be stored here',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Choice Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickCustomFolder,
                            icon: const Icon(
                              Icons.create_new_folder_outlined,
                              size: 18,
                            ),
                            label: const Text('Choose Folder'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: AppColors.primaryPurple,
                              side: const BorderSide(
                                color: AppColors.primaryPurple,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _useDefaultFolder,
                            icon: const Icon(
                              Icons.settings_suggest_rounded,
                              size: 18,
                            ),
                            label: const Text('Use Default'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: isDark
                                  ? AppColors.lightText
                                  : AppColors.secondaryText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onContinue,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: AppColors.white,
                          elevation: 4,
                          shadowColor: AppColors.primaryPurple.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
