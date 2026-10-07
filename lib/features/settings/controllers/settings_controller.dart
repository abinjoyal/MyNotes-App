import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class SettingsController extends ChangeNotifier {
  static final SettingsController instance = SettingsController._internal();

  factory SettingsController() {
    return instance;
  }

  SettingsController._internal();

  // Appearance State
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedTheme = 'System'; // 'Light', 'Dark', 'System'
  String _selectedLayout = 'Grid'; // 'Grid', 'List'
  String _fontSize = 'Medium'; // 'Small', 'Medium', 'Large'

  // Security State
  bool _enablePinLock = false;
  bool _enableBiometrics = false;
  String _pinCode = '';

  // Cloud & Backup State
  bool _enableCloudSync = true;
  String _backupFrequency = 'Daily';
  bool _autoCleanTrash = true;
  String _fileFormat = 'Markdown (.md)'; // 'Markdown (.md)', 'Text (.txt)', 'JSON (.json)'

  // Load persisted settings from disk
  Future<void> loadSettings() async {
    final storage = StorageService.instance;
    await storage.init();

    _enablePinLock = storage.getBool('enable_pin_lock', defaultValue: false);
    _pinCode = storage.getString('pin_code', defaultValue: '');
    _enableBiometrics = storage.getBool('enable_biometrics', defaultValue: false);
    _selectedTheme = storage.getString('selected_theme', defaultValue: 'System');
    _selectedLayout = storage.getString('selected_layout', defaultValue: 'Grid');
    _fontSize = storage.getString('font_size', defaultValue: 'Medium');
    _autoCleanTrash = storage.getBool('auto_clean_trash', defaultValue: true);
    _enableCloudSync = storage.getBool('enable_cloud_sync', defaultValue: true);
    _backupFrequency = storage.getString('backup_frequency', defaultValue: 'Daily');
    _fileFormat = storage.getString('file_format', defaultValue: 'Markdown (.md)');

    switch (_selectedTheme) {
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
  String get fileFormat => _fileFormat;

  String get fileExtension {
    switch (_fileFormat) {
      case 'Text (.txt)':
        return '.txt';
      case 'JSON (.json)':
        return '.json';
      case 'Markdown (.md)':
      default:
        return '.md';
    }
  }

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
    StorageService.instance.saveString('selected_theme', theme);
    notifyListeners();
  }

  void updateLayout(String layout) {
    _selectedLayout = layout;
    StorageService.instance.saveString('selected_layout', layout);
    notifyListeners();
  }

  void updateFontSize(String size) {
    _fontSize = size;
    StorageService.instance.saveString('font_size', size);
    notifyListeners();
  }

  void updateFileFormat(String format) {
    _fileFormat = format;
    StorageService.instance.saveString('file_format', format);
    notifyListeners();
  }

  void togglePinLock(bool value) {
    _enablePinLock = value;
    if (!value) {
      _enableBiometrics = false;
      StorageService.instance.saveBool('enable_biometrics', false);
    }
    StorageService.instance.saveBool('enable_pin_lock', value);
    notifyListeners();
  }

  void setPinCode(String pin) {
    _pinCode = pin;
    _enablePinLock = true;
    StorageService.instance.saveString('pin_code', pin);
    StorageService.instance.saveBool('enable_pin_lock', true);
    notifyListeners();
  }

  bool verifyPin(String inputPin) {
    return _pinCode == inputPin;
  }

  void toggleBiometrics(bool value) {
    _enableBiometrics = value;
    StorageService.instance.saveBool('enable_biometrics', value);
    notifyListeners();
  }

  void toggleCloudSync(bool value) {
    _enableCloudSync = value;
    StorageService.instance.saveBool('enable_cloud_sync', value);
    notifyListeners();
  }

  void updateBackupFrequency(String freq) {
    _backupFrequency = freq;
    StorageService.instance.saveString('backup_frequency', freq);
    notifyListeners();
  }

  void toggleAutoCleanTrash(bool value) {
    _autoCleanTrash = value;
    StorageService.instance.saveBool('auto_clean_trash', value);
    notifyListeners();
  }
}
