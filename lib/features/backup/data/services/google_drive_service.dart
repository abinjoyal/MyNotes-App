import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:mynotes/features/settings/presentation/controllers/settings_controller.dart';
import 'backup_service.dart';

class GoogleDriveService extends ChangeNotifier {
  static final GoogleDriveService instance = GoogleDriveService._internal();
  factory GoogleDriveService() => instance;
  GoogleDriveService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  bool _isSyncing = false;
  String? _lastSyncTimestamp;

  bool get isConnected => _currentUser != null;
  bool get isSyncing => _isSyncing;
  String? get currentUserEmail => _currentUser?.email;
  String? get currentUserName => _currentUser?.displayName;
  String? get currentUserPhotoUrl => _currentUser?.photoUrl;
  String get lastSyncTimestamp => _lastSyncTimestamp ?? SettingsController.instance.lastBackupTime;

  /// Connects user Google Account
  Future<bool> connectAccount() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign In Error: $e');
      }
      // Demo / Fallback connection simulation if OAuth client ID is not configured yet
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  /// Disconnects connected Google Account
  Future<void> disconnectAccount() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }

  /// Backup current notes JSON payload to Google Drive
  Future<bool> uploadBackupToDrive() async {
    if (_currentUser == null) {
      // Connect first if not signed in
      final connected = await connectAccount();
      if (!connected && _currentUser == null) return false;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        _isSyncing = false;
        notifyListeners();
        return false;
      }

      final driveApi = drive.DriveApi(httpClient);
      final payload = BackupService.instance.createBackupPayload();

      // Check if mynotes_backup.json already exists in appDataFolder
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'mynotes_backup.json' and trashed = false",
      );

      final mediaContent = drive.Media(
        Stream.value(utf8.encode(payload.jsonContent)),
        utf8.encode(payload.jsonContent).length,
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing file
        final existingFileId = fileList.files!.first.id!;
        await driveApi.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: mediaContent,
        );
      } else {
        // Create new backup file
        final driveFile = drive.File()
          ..name = 'mynotes_backup.json'
          ..parents = ['appDataFolder'];
        await driveApi.files.create(
          driveFile,
          uploadMedia: mediaContent,
        );
      }

      _lastSyncTimestamp = payload.timestamp;
      SettingsController.instance.updateLastBackupTime(
        payload.timestamp,
        payload.formattedSize,
      );

      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Google Drive Upload Error: $e');
      }
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  /// Restores notes from Google Drive backup
  Future<bool> restoreBackupFromDrive() async {
    if (_currentUser == null) {
      final connected = await connectAccount();
      if (!connected && _currentUser == null) return false;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        _isSyncing = false;
        notifyListeners();
        return false;
      }

      final driveApi = drive.DriveApi(httpClient);

      // Search for mynotes_backup.json in appDataFolder
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'mynotes_backup.json' and trashed = false",
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        _isSyncing = false;
        notifyListeners();
        return false;
      }

      final fileId = fileList.files!.first.id!;
      final driveFile = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataBytes = [];
      await for (final chunk in driveFile.stream) {
        dataBytes.addAll(chunk);
      }

      final jsonStr = utf8.decode(dataBytes);
      final success = BackupService.instance.restoreFromBackupPayload(jsonStr);

      _isSyncing = false;
      notifyListeners();
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Google Drive Restore Error: $e');
      }
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }
}
