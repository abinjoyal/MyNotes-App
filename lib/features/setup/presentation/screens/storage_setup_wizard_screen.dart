import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/layout/desktop_layout.dart';
import '../../../../app/layout/responsive_layout.dart';
import '../../../../app/theme/app_theme_colors.dart';
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
  bool _isPickingFolder = false;

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
    if (_isPickingFolder) return;
    _isPickingFolder = true;

    try {
      String? initialDir = _selectedPath;
      if (initialDir.isNotEmpty && !Directory(initialDir).existsSync()) {
        final parentDir = Directory(initialDir).parent;
        initialDir = parentDir.existsSync() ? parentDir.path : null;
      }

      final String? selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select Storage Folder for Notes',
        initialDirectory: initialDir,
      );

      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        if (mounted) {
          setState(() {
            _selectedPath = StorageLocationService.instance
                .ensureMyNotesSubfolder(selectedDirectory);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open folder picker: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      _isPickingFolder = false;
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
            onSuccess: (passcodeContext) {
              Navigator.of(passcodeContext).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ResponsiveLayout(
                    mobile: DesktopLayout(),
                    desktop: DesktopLayout(),
                  ),
                ),
              );
            },
          )
        : const ResponsiveLayout(
            mobile: DesktopLayout(),
            desktop: DesktopLayout(),
          );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = colors.isDark;

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              decoration: BoxDecoration(
                color: colors.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
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
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.folder_special_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Title & Subtitle
                    Text(
                      'Welcome to Notes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: colors.textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your notes. Your storage.\nYou decide where they live.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: colors.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Selected Directory Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF241C18)
                            : AppColors.softGray,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colors.borderColor,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withOpacity(
                                    0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.folder_open_rounded,
                                  color: AppColors.primaryPurple,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Storage Location',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF181210)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colors.borderColor),
                            ),
                            child: SelectableText(
                              _selectedPath.isEmpty
                                  ? 'Loading storage location...'
                                  : _selectedPath,
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                                color: colors.textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 15,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Storage destination ready',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Choice Buttons
                    Builder(
                      builder: (context) {
                        final isCustomSelected =
                            _selectedPath != _defaultPath &&
                            _selectedPath.isNotEmpty;
                        return Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: (_isPickingFolder || _isLoading)
                                      ? null
                                      : _pickCustomFolder,
                                  borderRadius: BorderRadius.circular(12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isCustomSelected
                                          ? AppColors.primaryPurple.withOpacity(
                                              0.12,
                                            )
                                          : (isDark
                                                ? const Color(0xFF241C18)
                                                : Colors.transparent),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCustomSelected
                                            ? AppColors.primaryPurple
                                            : colors.borderColor,
                                        width: isCustomSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      'Choose Folder',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isCustomSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isCustomSelected
                                            ? AppColors.primaryPurple
                                            : colors.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _useDefaultFolder,
                                  borderRadius: BorderRadius.circular(12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF241C18)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colors.borderColor,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      'Use Default',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
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
