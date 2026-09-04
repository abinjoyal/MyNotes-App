import 'package:flutter/material.dart';
import 'package:mynotes/features/backup/data/services/backup_service.dart';


class SettingsController extends ChangeNotifier {
  static final SettingsController instance = SettingsController._internal();

  factory SettingsController() {
    return instance;
  }

  SettingsController._internal();

  // Appearance State
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedTheme = 'System'; // 'Light', 'Dark', 'System'
  String _selectedLayout = 'Grid';  // 'Grid', 'List'
  String _fontSize = 'Medium';       // 'Small', 'Medium', 'Large'

  // Security State
  bool _enablePinLock = false;
  bool _enableBiometrics = false;
  String _pinCode = '';

  // Cloud & Backup State
  bool _enableCloudSync = true;
  String _backupFrequency = 'Daily';
  bool _autoCleanTrash = true;
  String _lastBackupTime = 'Never';
  String _lastBackupSize = '0 B';
  String _latestBackupJson = '';

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get selectedTheme => _selectedTheme;
  String get selectedLayout => _selectedLayout;
  String get fontSize => _fontSize;
  bool get isGridView => _selectedLayout == 'Grid';

  double get fontSizeValue {
    switch (_fontSize) {
      case 'Small':
        return 13.0;
      case 'Large':
        return 18.0;
      case 'Medium':
      default:
        return 15.0;
    }
  }

  bool get enablePinLock => _enablePinLock;
  bool get enableBiometrics => _enableBiometrics;
  bool get hasPinCode => _pinCode.isNotEmpty;
  String get pinCode => _pinCode;
  bool get enableCloudSync => _enableCloudSync;
  String get backupFrequency => _backupFrequency;
  bool get autoCleanTrash => _autoCleanTrash;
  String get lastBackupTime => _lastBackupTime;
  String get lastBackupSize => _lastBackupSize;
  String get latestBackupJson => _latestBackupJson;

  // Actions
  void updateTheme(String theme) {
    _selectedTheme = theme;
    switch (theme) {
      case 'Light':
        _themeMode = ThemeMode.light;
        break;
      case 'Dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'System':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  void updateLayout(String layout) {
    _selectedLayout = layout;
    notifyListeners();
  }

  void updateFontSize(String size) {
    _fontSize = size;
    notifyListeners();
  }

  void togglePinLock(bool value) {
    _enablePinLock = value;
    if (!value) {
      _enableBiometrics = false;
    }
    notifyListeners();
  }

  void setPinCode(String pin) {
    _pinCode = pin;
    _enablePinLock = true;
    notifyListeners();
  }

  bool verifyPin(String inputPin) {
    return _pinCode == inputPin;
  }

  void toggleBiometrics(bool value) {
    _enableBiometrics = value;
    notifyListeners();
  }

  void toggleCloudSync(bool value) {
    _enableCloudSync = value;
    notifyListeners();
  }

  void updateBackupFrequency(String freq) {
    _backupFrequency = freq;
    notifyListeners();
  }

  void toggleAutoCleanTrash(bool value) {
    _autoCleanTrash = value;
    notifyListeners();
  }

  BackupResult performBackup() {
    final result = BackupService.instance.createBackupPayload();
    _lastBackupTime = result.timestamp;
    _lastBackupSize = result.formattedSize;
    _latestBackupJson = result.jsonContent;
    notifyListeners();
    return result;
  }

  bool restoreBackup(String jsonStr) {
    final success = BackupService.instance.restoreFromBackupPayload(jsonStr);
    if (success) {
      notifyListeners();
    }
    return success;
  }
}
