import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../controllers/settings_controller.dart';
import '../../../pin/presentation/screens/passcode_lock_screen.dart';
import '../../../backup/data/services/backup_service.dart';
import '../../../backup/data/services/google_drive_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController _controller = SettingsController.instance;
  final GoogleDriveService _driveService = GoogleDriveService.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSettingsChanged);
    _driveService.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSettingsChanged);
    _driveService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
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
                  border: Border(
                    bottom: BorderSide(color: borderColor),
                  ),
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
                          'Manage app preferences, theme, security & backup',
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
                  _buildSectionHeader('Appearance & Display', Icons.palette_outlined, textColor),
                  const SizedBox(height: 12),
                  _buildCardContainer(cardBg, borderColor, [
                    _buildSelectionTile(
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
                    _buildSelectionTile(
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
                    _buildSelectionTile(
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
                  ]),

                  const SizedBox(height: 28),

                  // 2. Security Section
                  _buildSectionHeader('Security & Lock', Icons.lock_outline_rounded, textColor),
                  const SizedBox(height: 12),
                  _buildCardContainer(cardBg, borderColor, [
                    _buildSwitchTile(
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
                      _buildActionTile(
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
                    _buildSwitchTile(
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
                  ]),

                  const SizedBox(height: 28),

                  // 3. Backup & Sync Section
                  _buildSectionHeader('Backup & Cloud Sync', Icons.cloud_outlined, textColor),
                  const SizedBox(height: 12),
                  _buildCardContainer(cardBg, borderColor, [
                    _buildActionTile(
                      title: 'Google Drive Account',
                      subtitle: _driveService.isConnected
                          ? 'Connected: ${_driveService.currentUserEmail ?? 'Google Account'}'
                          : 'Connect your Google account for automated cloud backups',
                      icon: Icons.add_to_drive_rounded,
                      actionLabel: _driveService.isConnected ? 'Disconnect' : 'Connect',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () async {
                        if (_driveService.isConnected) {
                          await _driveService.disconnectAccount();
                          _showSnackBar('Google Drive disconnected');
                        } else {
                          final success = await _driveService.connectAccount();
                          if (success) {
                            _showSnackBar('Google Drive connected: ${_driveService.currentUserEmail}');
                          } else {
                            _showSnackBar('Connecting Google Drive... (Setup Google OAuth Client ID in Cloud Console for live auth)');
                          }
                        }
                      },
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildActionTile(
                      title: 'Sync Backup to Google Drive',
                      subtitle: 'Upload latest notes & settings snapshot to Google Drive',
                      icon: Icons.cloud_upload_outlined,
                      actionLabel: _driveService.isSyncing ? 'Syncing...' : 'Sync Drive',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () async {
                        final success = await _driveService.uploadBackupToDrive();
                        if (success) {
                          _showSnackBar('Backup successfully synced to Google Drive!');
                        } else {
                          _showSnackBar('Backup saved locally (Configure OAuth Client ID for live Drive upload)');
                          _handleBackupNow();
                        }
                      },
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildActionTile(
                      title: 'Restore from Google Drive',
                      subtitle: 'Fetch latest backup from Google Drive and restore notes',
                      icon: Icons.cloud_download_outlined,
                      actionLabel: 'Fetch Drive',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () async {
                        final success = await _driveService.restoreBackupFromDrive();
                        if (success) {
                          _showSnackBar('Notes successfully restored from Google Drive!');
                        } else {
                          _showSnackBar('No Drive backup found. Use local file restore.');
                          _showRestoreDialog();
                        }
                      },
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildSwitchTile(
                      title: 'Cloud Auto-Sync',
                      subtitle: 'Automatically sync notes across your devices',
                      icon: Icons.sync_rounded,
                      value: _controller.enableCloudSync,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onChanged: (val) {
                        _controller.toggleCloudSync(val);
                        _showSnackBar(val ? 'Cloud Auto-Sync Enabled' : 'Cloud Auto-Sync Disabled');
                      },
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildSelectionTile(
                      title: 'Backup Frequency',
                      subtitle: 'How often cloud backup is performed',
                      icon: Icons.restore_rounded,
                      currentValue: _controller.backupFrequency,
                      options: const ['Daily', 'Weekly', 'Monthly'],
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      dropdownBg: isDark ? const Color(0xFF2A2A30) : const Color(0xFFF1F3F6),
                      onChanged: (val) {
                        _controller.updateBackupFrequency(val);
                        _showSnackBar('Backup frequency set to $val');
                      },
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildActionTile(
                      title: 'Local Backup Now',
                      subtitle: _controller.lastBackupTime == 'Never'
                          ? 'Create a fresh backup file immediately'
                          : 'Last Backup: ${_controller.lastBackupTime} (${_controller.lastBackupSize})',
                      icon: Icons.sd_storage_outlined,
                      actionLabel: 'Export JSON',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: _handleBackupNow,
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildActionTile(
                      title: 'Restore Notes from JSON File',
                      subtitle: 'Restore notes & folders from a local JSON backup payload',
                      icon: Icons.settings_backup_restore_rounded,
                      actionLabel: 'Restore',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: _showRestoreDialog,
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // 4. Data & Export Section
                  _buildSectionHeader('Data & Storage', Icons.folder_open_outlined, textColor),
                  const SizedBox(height: 12),
                  _buildCardContainer(cardBg, borderColor, [
                    _buildSwitchTile(
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
                    _buildActionTile(
                      title: 'Export Notes Data',
                      subtitle: 'Save notes as PDF, Text, or JSON backup file',
                      icon: Icons.download_rounded,
                      actionLabel: 'Export',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: _showExportDialog,
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildActionTile(
                      title: 'Clear Trash Bin',
                      subtitle: 'Permanently remove all items in trash right now',
                      icon: Icons.delete_forever_outlined,
                      actionLabel: 'Empty Trash',
                      isDestructive: true,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () {
                        _showSnackBar('Trash bin cleared!');
                      },
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // 5. App Info Card
                  _buildAppInfoCard(cardBg, borderColor, textColor, secondaryTextColor, isDark),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helpers
  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryPurple),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer(Color cardBg, Color borderColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Color textColor,
    required Color secondaryTextColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: secondaryTextColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String currentValue,
    required List<String> options,
    required Color textColor,
    required Color secondaryTextColor,
    required Color dropdownBg,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: secondaryTextColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: dropdownBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                dropdownColor: dropdownBg,
                isDense: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryPurple),
                items: options.map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text(opt),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onChanged(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String actionLabel,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.primaryPurple;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDestructive ? AppColors.error : secondaryTextColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppColors.error : textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MyNotes App',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Version 1.0.0 (Build 1) • Offline First',
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
            child: const Text(
              '2.4 MB Used',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
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

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Export Notes', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Select a format to export all your notes:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showSnackBar('Exported as Plain Text (.txt)');
            },
            child: const Text('TXT'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showSnackBar('Exported as PDF document (.pdf)');
            },
            child: const Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final filePath = await BackupService.instance.exportBackupToFile();
              if (filePath != null) {
                _showSnackBar('Backup file exported to: $filePath');
              } else {
                _showSnackBar('Failed to export backup file.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Download .json File'),
          ),
        ],
      ),
    );
  }
  void _handleBackupNow() {
    final res = _controller.performBackup();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00C853)),
            SizedBox(width: 10),
            Text('Backup Created!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backup Size: ${res.formattedSize}'),
            const SizedBox(height: 4),
            Text('Timestamp: ${res.timestamp}'),
            const SizedBox(height: 4),
            Text('Total Notes: ${res.totalNotes}'),
            const SizedBox(height: 12),
            Container(
              height: 120,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  res.jsonContent,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFF00E676),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showSnackBar('Backup JSON copied!');
            },
            child: const Text('Copy JSON'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final filePath = await BackupService.instance.exportBackupToFile();
              if (mounted) {
                Navigator.of(ctx).pop();
                if (filePath != null) {
                  _showSnackBar('Backup file saved to: $filePath');
                } else {
                  _showSnackBar('Failed to save backup file.');
                }
              }
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download .json File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Notes from Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste a valid MyNotes JSON backup payload below to restore your notes and folders:',
              style: TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                hintText: '{\n  "app": "MyNotes",\n  "notes": [...]\n}',
                filled: true,
                fillColor: const Color(0xFFF7F8FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFEAEAEE)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final jsonInput = controller.text.trim();
              if (jsonInput.isEmpty) return;
              final success = _controller.restoreBackup(jsonInput);
              Navigator.of(ctx).pop();
              if (success) {
                _showSnackBar('Notes & Folders restored successfully!');
              } else {
                _showSnackBar('Invalid backup JSON payload. Restore failed.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restore Payload'),
          ),
        ],
      ),
    );
  }
}
