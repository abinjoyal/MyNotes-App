import 'dart:convert';
import 'dart:io';

class StorageService {
  static final StorageService instance = StorageService._internal();
  factory StorageService() => instance;
  StorageService._internal();

  bool _isInitialized = false;
  late File _settingsFile;
  Map<String, dynamic> _preferences = {};

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final dir = Directory.current;
      final dbDir = Directory('${dir.path}/database');
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      _settingsFile = File('${dbDir.path}/app_settings.json');
      if (await _settingsFile.exists()) {
        final content = await _settingsFile.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            _preferences = decoded;
          }
        }
      } else {
        await _flushToDisk();
      }
    } catch (_) {}

    _isInitialized = true;
  }

  String getString(String key, {String defaultValue = ''}) {
    final val = _preferences[key];
    return val is String ? val : defaultValue;
  }

  Future<void> saveString(String key, String value) async {
    await init();
    _preferences[key] = value;
    await _flushToDisk();
  }

  bool getBool(String key, {bool defaultValue = false}) {
    final val = _preferences[key];
    return val is bool ? val : defaultValue;
  }

  Future<void> saveBool(String key, bool value) async {
    await init();
    _preferences[key] = value;
    await _flushToDisk();
  }

  int getInt(String key, {int defaultValue = 0}) {
    final val = _preferences[key];
    return val is int ? val : defaultValue;
  }

  Future<void> saveInt(String key, int value) async {
    await init();
    _preferences[key] = value;
    await _flushToDisk();
  }

  Future<void> _flushToDisk() async {
    try {
      final jsonStr = const JsonEncoder.withIndent('  ').convert(_preferences);
      await _settingsFile.writeAsString(jsonStr);
    } catch (_) {}
  }
}
