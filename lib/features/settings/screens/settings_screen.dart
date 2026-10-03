import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/constants/app_colors.dart';
import '../../../core/services/storage_location_service.dart';
import '../../notes/presentation/controllers/notes_controller.dart';
import '../../pin/presentation/screens/passcode_lock_screen.dart';
import '../controllers/settings_controller.dart';
import '../widgets/app_info_card.dart';
import '../widgets/setting_action_tile.dart';
import '../widgets/setting_card_container.dart';
import '../widgets/setting_section_header.dart';
import '../widgets/setting_selection_tile.dart';
import '../widgets/setting_switch_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController _controller = SettingsController.instance;
  String _currentStoragePath = '';
  String _storageUsage = '0.0 MB';

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    final path = await StorageLocationService.instance.getStoragePath();
    final usage = await StorageLocationService.instance.getFormattedStorageUsage(path);
    if (!mounted) return;
    setState(() {
      _currentStoragePath = path;
      _storageUsage = usage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkScaffoldBackground : const Color(0xFFF9FAFC);
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFEAEAEE);
    final secondaryTextColor = isDark ? const Color(0xFF98A2B3) : AppColors.secondaryText;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Header App Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryPurple.withOpacity(0.2)
                            : AppColors.lightLavender,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.primaryPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage app preferences, theme, security & storage',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Settings Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Appearance Section
                  SettingSectionHeader(
                    title: 'Appearance & Display',
                    icon: Icons.palette_outlined,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  SettingCardContainer(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    children: [
                      SettingSelectionTile(
                        title: 'Theme Mode',
                        subtitle: 'Choose your preferred visual theme',
                        icon: Icons.brightness_6_outlined,
                        currentValue: _controller.selectedTheme,
                        options: const ['Light', 'Dark', 'System'],
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        dropdownBg: isDark ? const Color(0xFF2A2A30) : const Color(0xFFF1F3F6),
                        onChanged: (val) {
                          _controller.updateTheme(val);
                          _showSnackBar('Theme updated to $val mode');
                        },
                      ),
                      Divider(height: 1, color: borderColor),
                      SettingSelectionTile(
                        title: 'Default Note Layout',
                        subtitle: 'Grid or List view on main dashboard',
                        icon: Icons.grid_view_rounded,
                        currentValue: _controller.selectedLayout,
                        options: const ['Grid', 'List'],
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        dropdownBg: isDark ? const Color(0xFF2A2A30) : const Color(0xFFF1F3F6),
                        onChanged: (val) {
                          _controller.updateLayout(val);
                          _showSnackBar('Default note view updated to $val');
                        },
                      ),
                      Divider(height: 1, color: borderColor),
                      SettingSelectionTile(
                        title: 'Editor Font Size',
                        subtitle: 'Text size inside note editor',
                        icon: Icons.format_size_rounded,
                        currentValue: _controller.fontSize,
                        options: const ['Small', 'Medium', 'Large'],
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        dropdownBg: isDark ? const Color(0xFF2A2A30) : const Color(0xFFF1F3F6),
                        onChanged: (val) {
                          _controller.updateFontSize(val);
                          _showSnackBar('Editor font size set to $val');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // 2. Security Section
                  SettingSectionHeader(
                    title: 'Security & Lock',
                    icon: Icons.lock_outline_rounded,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  SettingCardContainer(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    children: [
                      SettingSwitchTile(
                        title: 'Passcode Lock',
                        subtitle: _controller.enablePinLock
                            ? 'PIN Lock Active (${_controller.pinCode.replaceAll(RegExp(r'.'), '•')})'
                            : 'Require PIN passcode when opening app',
                        icon: Icons.pin_outlined,
                        value: _controller.enablePinLock,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onChanged: (val) async {
                          if (val) {
                            final setupSuccess = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => const PasscodeLockScreen(isSetupMode: true),
                              ),
                            );
                            if (setupSuccess == true) {
                              _showSnackBar('PIN Passcode set successfully!');
                            }
                          } else {
                            _controller.togglePinLock(false);
                            _showSnackBar('PIN Passcode Disabled');
                          }
                        },
                      ),
                      if (_controller.enablePinLock) ...[
                        Divider(height: 1, color: borderColor),
                        SettingActionTile(
                          title: 'Change Passcode',
                          subtitle: 'Update your 4-digit security PIN',
                          icon: Icons.password_rounded,
                          actionLabel: 'Change',
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          onTap: () async {
                            final setupSuccess = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => const PasscodeLockScreen(isSetupMode: true),
                              ),
                            );
                            if (setupSuccess == true) {
                              _showSnackBar('Passcode updated successfully!');
                            }
                          },
                        ),
                      ],
                      Divider(height: 1, color: borderColor),
                      SettingSwitchTile(
                        title: 'Biometric Authentication',
                        subtitle: 'Use Fingerprint / Face ID to unlock notes',
                        icon: Icons.fingerprint_rounded,
                        value: _controller.enableBiometrics,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onChanged: (val) {
                          if (val && !_controller.enablePinLock) {
                            _showSnackBar('Please enable Passcode Lock first');
                          } else {
                            _controller.toggleBiometrics(val);
                            _showSnackBar(val ? 'Biometric Authentication Enabled' : 'Biometric Auth Disabled');
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // 3. Data & Storage Section
                  SettingSectionHeader(
                    title: 'Data & Storage Location',
                    icon: Icons.folder_open_outlined,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 12),
                  SettingCardContainer(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    children: [
                      SettingActionTile(
                        title: 'Storage Location',
                        subtitle: _currentStoragePath.isEmpty ? 'Loading path...' : _currentStoragePath,
                        icon: Icons.folder_special_rounded,
                        actionLabel: 'Change',
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: _onChangeStorageClick,
                      ),
                      Divider(height: 1, color: borderColor),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.pie_chart_outline_rounded, size: 20, color: secondaryTextColor),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Storage Usage',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Total size of local notes, tasks & folders',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primaryPurple.withOpacity(0.2)
                                    : AppColors.lightLavender,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _storageUsage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: borderColor),
                      SettingSwitchTile(
                        title: 'Auto-Clean Trash',
                        subtitle: 'Permanently remove notes deleted over 30 days ago',
                        icon: Icons.auto_delete_outlined,
                        value: _controller.autoCleanTrash,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onChanged: (val) {
                          _controller.toggleAutoCleanTrash(val);
                          _showSnackBar(val ? 'Auto-clean trash enabled' : 'Auto-clean trash disabled');
                        },
                      ),
                      Divider(height: 1, color: borderColor),
                      SettingActionTile(
                        title: 'Export Notes Data',
                        subtitle: 'Compress and download all notes, tasks & folders as MyNotes_Backup.zip',
                        icon: Icons.archive_rounded,
                        actionLabel: 'Export ZIP',
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: _onExportZipClick,
                      ),
                      Divider(height: 1, color: borderColor),
                      SettingActionTile(
                        title: 'Clear Trash Bin',
                        subtitle: 'Permanently remove all items in trash right now',
                        icon: Icons.delete_forever_outlined,
                        actionLabel: 'Empty Trash',
                        isDestructive: true,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          NotesController.instance.emptyTrash();
                          _showSnackBar('Trash bin cleared!');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // 4. App Info Card
                  AppInfoCard(
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _onChangeStorageClick() async {
    try {
      String? initialDir = _currentStoragePath;
      if (initialDir.isNotEmpty && !Directory(initialDir).existsSync()) {
        final parentDir = Directory(initialDir).parent;
        initialDir = parentDir.existsSync() ? parentDir.path : null;
      }

      final String? selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select New Storage Folder for MyNotes',
        initialDirectory: initialDir,
      );

      if (selectedDirectory == null || selectedDirectory.isEmpty || selectedDirectory == _currentStoragePath) {
        return;
      }

      if (!mounted) return;
      _showMigrationDialog(selectedDirectory);
    } catch (e) {
      _showSnackBar('Could not open folder picker: $e');
    }
  }

  void _showMigrationDialog(String newPath) {
    StorageMigrationOption selectedOption = StorageMigrationOption.move;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.drive_file_move_rounded, color: AppColors.primaryPurple),
                  SizedBox(width: 10),
                  Text('Change Storage Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Where should your existing data go?',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<StorageMigrationOption>(
                    title: const Text('Move existing notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Transfer files from old folder to new folder', style: TextStyle(fontSize: 11)),
                    value: StorageMigrationOption.move,
                    groupValue: selectedOption,
                    activeColor: AppColors.primaryPurple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedOption = val);
                    },
                  ),
                  RadioListTile<StorageMigrationOption>(
                    title: const Text('Copy existing notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Duplicate files to new folder, keep old copy', style: TextStyle(fontSize: 11)),
                    value: StorageMigrationOption.copy,
                    groupValue: selectedOption,
                    activeColor: AppColors.primaryPurple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedOption = val);
                    },
                  ),
                  RadioListTile<StorageMigrationOption>(
                    title: const Text('Use new folder only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Switch active folder without touching old files', style: TextStyle(fontSize: 11)),
                    value: StorageMigrationOption.switchOnly,
                    groupValue: selectedOption,
                    activeColor: AppColors.primaryPurple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedOption = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    _showSnackBar('Migrating storage data...');
                    await StorageLocationService.instance.changeStoragePath(
                      oldPath: _currentStoragePath,
                      newPath: newPath,
                      option: selectedOption,
                    );
                    await _loadStorageInfo();
                    _showSnackBar('Storage folder changed successfully!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _onExportZipClick() async {
    _showSnackBar('Generating MyNotes_Backup.zip...');
    final zipFile = await StorageLocationService.instance.createZipBackup();
    if (zipFile == null || !await zipFile.exists()) {
      _showSnackBar('Could not create ZIP backup archive');
      return;
    }

    try {
      await Share.shareXFiles(
        [XFile(zipFile.path)],
        subject: 'MyNotes Backup Archive (.zip)',
        text: 'Here is your complete MyNotes backup archive containing all notes, tasks, and folders.',
      );
      _showSnackBar('MyNotes_Backup.zip export ready!');
    } catch (e) {
      _showSnackBar('Backup ZIP created at: ${zipFile.path}');
    }
  }
}
