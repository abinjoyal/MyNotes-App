import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/theme/app_theme_colors.dart';
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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = SettingsController.instance;
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Header App Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: colors.cardBg,
                  border: Border(bottom: BorderSide(color: colors.borderColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.isDark
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
                            color: colors.textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage app preferences, theme, security & storage',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.secondaryTextColor,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Appearance Section
                  SettingSectionHeader(
                    title: 'Appearance & Display',
                    icon: Icons.palette_outlined,
                    textColor: colors.textColor,
                  ),
                  const SizedBox(height: 12),
                  SettingCardContainer(
                    cardBg: colors.cardBg,
                    borderColor: colors.borderColor,
                    children: [
                      SettingSelectionTile(
                        title: 'Theme Mode',
                        subtitle: 'Choose your preferred visual theme',
                        icon: Icons.brightness_6_outlined,
                        currentValue: controller.selectedTheme,
                        options: const ['Light', 'Dark', 'System'],
                        textColor: colors.textColor,
                        secondaryTextColor: colors.secondaryTextColor,
                        dropdownBg: colors.dropdownBg,
                        onChanged: (val) {
                          controller.updateTheme(val);
                          _showSnackBar(context, 'Theme updated to $val mode');
                        },
                      ),
                      Divider(height: 1, color: colors.borderColor),
                      SettingSelectionTile(
                        title: 'Default Note Layout',
                        subtitle: 'Grid or List view on main dashboard',
                        icon: Icons.grid_view_rounded,
                        currentValue: controller.selectedLayout,
                        options: const ['Grid', 'List'],
                        textColor: colors.textColor,
                        secondaryTextColor: colors.secondaryTextColor,
                        dropdownBg: colors.dropdownBg,
                        onChanged: (val) {
                          controller.updateLayout(val);
                          _showSnackBar(
                            context,
                            'Default note view updated to $val',
                          );
                        },
                      ),
                      Divider(height: 1, color: colors.borderColor),
                      SettingSelectionTile(
                        title: 'Editor Font Size',
                        subtitle: 'Text size inside note editor',
                        icon: Icons.format_size_rounded,
                        currentValue: controller.fontSize,
                        options: const ['Small', 'Medium', 'Large'],
                        textColor: colors.textColor,
                        secondaryTextColor: colors.secondaryTextColor,
                        dropdownBg: colors.dropdownBg,
                        onChanged: (val) {
                          controller.updateFontSize(val);
                          _showSnackBar(
                            context,
                            'Editor font size set to $val',
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // 2. Security Section
                  SettingSectionHeader(
                    title: 'Security & Lock',
                    icon: Icons.lock_outline_rounded,
                    textColor: colors.textColor,
                  ),
                  const SizedBox(height: 12),
                  SettingCardContainer(
                    cardBg: colors.cardBg,
                    borderColor: colors.borderColor,
                    children: [
                      SettingSwitchTile(
                        title: 'Passcode Lock',
                        subtitle: controller.enablePinLock
                            ? 'PIN Lock Active (${controller.pinCode.replaceAll(RegExp(r'.'), '•')})'
                            : 'Require PIN passcode when opening app',
                        icon: Icons.pin_outlined,
                        value: controller.enablePinLock,
                        textColor: colors.textColor,
                        secondaryTextColor: colors.secondaryTextColor,
                        onChanged: (val) async {
                          if (val) {
                            final setupSuccess = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const PasscodeLockScreen(
                                      isSetupMode: true,
                                    ),
                                  ),
                                );
                            if (setupSuccess == true) {
                              _showSnackBar(
                                context,
                                'PIN Passcode set successfully!',
                              );
                            }
                          } else {
                            controller.togglePinLock(false);
                            _showSnackBar(context, 'PIN Passcode Disabled');
                          }
                        },
                      ),
                      if (controller.enablePinLock) ...[
                        Divider(height: 1, color: colors.borderColor),
                        SettingActionTile(
                          title: 'Change Passcode',
                          subtitle: 'Update your 4-digit security PIN',
                          icon: Icons.password_rounded,
                          actionLabel: 'Change',
                          textColor: colors.textColor,
                          secondaryTextColor: colors.secondaryTextColor,
                          onTap: () async {
                            final setupSuccess = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const PasscodeLockScreen(
                                      isSetupMode: true,
                                    ),
                                  ),
                                );
                            if (setupSuccess == true) {
                              _showSnackBar(
                                context,
                                'Passcode updated successfully!',
                              );
                            }
                          },
                        ),
                      ],
                      Divider(height: 1, color: colors.borderColor),
                      SettingSwitchTile(
                        title: 'Biometric Authentication',
                        subtitle: 'Use Fingerprint / Face ID to unlock notes',
                        icon: Icons.fingerprint_rounded,
                        value: controller.enableBiometrics,
                        textColor: colors.textColor,
                        secondaryTextColor: colors.secondaryTextColor,
                        onChanged: (val) {
                          if (val && !controller.enablePinLock) {
                            _showSnackBar(
                              context,
                              'Please enable Passcode Lock first',
                            );
                          } else {
                            controller.toggleBiometrics(val);
                            _showSnackBar(
                              context,
                              val
                                  ? 'Biometric Authentication Enabled'
                                  : 'Biometric Auth Disabled',
                            );
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
                    textColor: colors.textColor,
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<Map<String, String>>(
                    future: _fetchStorageDetails(),
                    builder: (context, snapshot) {
                      final path =
                          snapshot.data?['path'] ?? 'Loading storage path...';
                      final usage = snapshot.data?['usage'] ?? '0.0 MB';

                      return SettingCardContainer(
                        cardBg: colors.cardBg,
                        borderColor: colors.borderColor,
                        children: [
                          SettingActionTile(
                            title: 'Storage Location',
                            subtitle: path,
                            icon: Icons.folder_special_rounded,
                            actionLabel: 'Change',
                            textColor: colors.textColor,
                            secondaryTextColor: colors.secondaryTextColor,
                            onTap: () => _onChangeStorageClick(context, path),
                          ),
                          Divider(height: 1, color: colors.borderColor),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.pie_chart_outline_rounded,
                                  size: 20,
                                  color: colors.secondaryTextColor,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Storage Usage',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Total size of local notes, tasks & folders',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.isDark
                                        ? AppColors.primaryPurple.withOpacity(
                                            0.2,
                                          )
                                        : AppColors.lightLavender,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    usage,
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
                          Divider(height: 1, color: colors.borderColor),
                          SettingSwitchTile(
                            title: 'Auto-Clean Trash',
                            subtitle:
                                'Permanently remove notes deleted over 30 days ago',
                            icon: Icons.auto_delete_outlined,
                            value: controller.autoCleanTrash,
                            textColor: colors.textColor,
                            secondaryTextColor: colors.secondaryTextColor,
                            onChanged: (val) {
                              controller.toggleAutoCleanTrash(val);
                              _showSnackBar(
                                context,
                                val
                                    ? 'Auto-clean trash enabled'
                                    : 'Auto-clean trash disabled',
                              );
                            },
                          ),
                          Divider(height: 1, color: colors.borderColor),
                          SettingActionTile(
                            title: 'Export Notes Data',
                            subtitle:
                                'Compress and download all notes, tasks & folders as MyNotes_Backup.zip',
                            icon: Icons.archive_rounded,
                            actionLabel: 'Export ZIP',
                            textColor: colors.textColor,
                            secondaryTextColor: colors.secondaryTextColor,
                            onTap: () => _onExportZipClick(context),
                          ),
                          Divider(height: 1, color: colors.borderColor),
                          SettingActionTile(
                            title: 'Clear Trash Bin',
                            subtitle:
                                'Permanently remove all items in trash right now',
                            icon: Icons.delete_forever_outlined,
                            actionLabel: 'Empty Trash',
                            isDestructive: true,
                            textColor: colors.textColor,
                            secondaryTextColor: colors.secondaryTextColor,
                            onTap: () {
                              NotesController.instance.emptyTrash();
                              _showSnackBar(context, 'Trash bin cleared!');
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // 4. App Info Card
                  AppInfoCard(
                    cardBg: colors.cardBg,
                    borderColor: colors.borderColor,
                    textColor: colors.textColor,
                    secondaryTextColor: colors.secondaryTextColor,
                    isDark: colors.isDark,
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

  static Future<Map<String, String>> _fetchStorageDetails() async {
    final path = await StorageLocationService.instance.getStoragePath();
    final usage = await StorageLocationService.instance
        .getFormattedStorageUsage(path);
    return {'path': path, 'usage': usage};
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static Future<void> _onChangeStorageClick(
    BuildContext context,
    String currentPath,
  ) async {
    try {
      String? initialDir = currentPath;
      if (initialDir.isNotEmpty && !Directory(initialDir).existsSync()) {
        final parentDir = Directory(initialDir).parent;
        initialDir = parentDir.existsSync() ? parentDir.path : null;
      }

      final String? selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select New Storage Folder for MyNotes',
        initialDirectory: initialDir,
      );

      if (selectedDirectory == null ||
          selectedDirectory.isEmpty ||
          selectedDirectory == currentPath) {
        return;
      }

      if (!context.mounted) return;
      _showMigrationDialog(context, currentPath, selectedDirectory);
    } catch (e) {
      _showSnackBar(context, 'Could not open folder picker: $e');
    }
  }

  static void _showMigrationDialog(
    BuildContext context,
    String currentPath,
    String newPath,
  ) {
    StorageMigrationOption selectedOption = StorageMigrationOption.move;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.drive_file_move_rounded,
                    color: AppColors.primaryPurple,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Change Storage Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
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
                    title: const Text(
                      'Move existing notes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Transfer files from old folder to new folder',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: StorageMigrationOption.move,
                    groupValue: selectedOption,
                    activeColor: AppColors.primaryPurple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null)
                        setDialogState(() => selectedOption = val);
                    },
                  ),
                  RadioListTile<StorageMigrationOption>(
                    title: const Text(
                      'Copy existing notes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Duplicate files to new folder, keep old copy',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: StorageMigrationOption.copy,
                    groupValue: selectedOption,
                    activeColor: AppColors.primaryPurple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null)
                        setDialogState(() => selectedOption = val);
                    },
                  ),
                  RadioListTile<StorageMigrationOption>(
                    title: const Text(
                      'Use new folder only',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Switch active folder without touching old files',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: StorageMigrationOption.switchOnly,
                    groupValue: selectedOption,
                    activeColor: AppColors.primaryPurple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      if (val != null)
                        setDialogState(() => selectedOption = val);
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
                    _showSnackBar(context, 'Migrating storage data...');
                    await StorageLocationService.instance.changeStoragePath(
                      oldPath: currentPath,
                      newPath: newPath,
                      option: selectedOption,
                    );
                    if (context.mounted) {
                      (context as Element).markNeedsBuild();
                      _showSnackBar(
                        context,
                        'Storage folder changed successfully!',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

  static Future<void> _onExportZipClick(BuildContext context) async {
    _showSnackBar(context, 'Generating MyNotes_Backup.zip...');
    final zipFile = await StorageLocationService.instance.createZipBackup();
    if (zipFile == null || !await zipFile.exists()) {
      _showSnackBar(context, 'Could not create ZIP backup archive');
      return;
    }

    try {
      await Share.shareXFiles(
        [XFile(zipFile.path)],
        subject: 'MyNotes Backup Archive (.zip)',
        text:
            'Here is your complete MyNotes backup archive containing all notes, tasks, and folders.',
      );
      _showSnackBar(context, 'MyNotes_Backup.zip export ready!');
    } catch (e) {
      _showSnackBar(context, 'Backup ZIP created at: ${zipFile.path}');
    }
  }
}
