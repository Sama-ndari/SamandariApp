import 'dart:io';
import 'package:hive/hive.dart';
import 'package:samapp/models/backup_settings.dart';
import 'package:samapp/services/backup_service.dart';

class AutoBackupService {
  final Box<BackupSettings> _settingsBox = Hive.box<BackupSettings>('backup_settings');
  final BackupService _backupService = BackupService();

  static const String _settingsKey = 'auto_backup_settings';

  // Initialize with default settings
  Future<void> init() async {
    if (_settingsBox.get(_settingsKey) == null) {
      final settings = BackupSettings()
        ..autoBackupEnabled = false
        ..backupFrequencyDays = 7 // Weekly by default
        ..lastBackupDate = null
        ..backupPath = '/storage/emulated/0/Download'
        ..maxBackupFiles = 5
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      
      await _settingsBox.put(_settingsKey, settings);
    }
  }

  // Get current settings
  BackupSettings? getSettings() {
    return _settingsBox.get(_settingsKey);
  }

  // Update settings
  Future<void> updateSettings(BackupSettings settings) async {
    settings.updatedAt = DateTime.now();
    await _settingsBox.put(_settingsKey, settings);
  }

  // Enable auto backup
  Future<void> enableAutoBackup({int frequencyDays = 7}) async {
    final settings = getSettings();
    if (settings != null) {
      settings.autoBackupEnabled = true;
      settings.backupFrequencyDays = frequencyDays;
      await updateSettings(settings);
    }
  }

  // Disable auto backup
  Future<void> disableAutoBackup() async {
    final settings = getSettings();
    if (settings != null) {
      settings.autoBackupEnabled = false;
      await updateSettings(settings);
    }
  }

  // Check if backup is needed
  bool shouldBackup() {
    final settings = getSettings();
    if (settings == null || !settings.autoBackupEnabled) {
      return false;
    }

    if (settings.lastBackupDate == null) {
      return true;
    }

    final daysSinceLastBackup = DateTime.now().difference(settings.lastBackupDate!).inDays;
    return daysSinceLastBackup >= settings.backupFrequencyDays;
  }

  // Perform auto backup
  Future<String?> performAutoBackup() async {
    if (!shouldBackup()) {
      return null;
    }

    try {
      final filePath = await _backupService.exportAllData();
      
      // Update last backup date
      final settings = getSettings();
      if (settings != null) {
        settings.lastBackupDate = DateTime.now();
        await updateSettings(settings);
      }

      // Clean old backups
      await _cleanOldBackups();

      return filePath;
    } catch (e) {
      print('Auto backup failed: $e');
      return null;
    }
  }

  // Clean old backup files
  Future<void> _cleanOldBackups() async {
    final settings = getSettings();
    if (settings == null) return;

    try {
      final backupDir = Directory(settings.backupPath);
      if (!await backupDir.exists()) return;

      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.contains('samandari_backup_'))
          .toList();

      // Sort by modification time (newest first)
      files.sort((a, b) {
        final aStat = (a as File).statSync();
        final bStat = (b as File).statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      // Delete old files beyond maxBackupFiles
      if (files.length > settings.maxBackupFiles) {
        for (int i = settings.maxBackupFiles; i < files.length; i++) {
          await (files[i] as File).delete();
        }
      }
    } catch (e) {
      print('Failed to clean old backups: $e');
    }
  }

  // Get backup status
  Map<String, dynamic> getBackupStatus() {
    final settings = getSettings();
    if (settings == null) {
      return {
        'enabled': false,
        'lastBackup': null,
        'nextBackup': null,
      };
    }

    DateTime? nextBackup;
    if (settings.lastBackupDate != null) {
      nextBackup = settings.lastBackupDate!.add(Duration(days: settings.backupFrequencyDays));
    }

    return {
      'enabled': settings.autoBackupEnabled,
      'frequency': settings.backupFrequencyDays,
      'lastBackup': settings.lastBackupDate,
      'nextBackup': nextBackup,
      'maxFiles': settings.maxBackupFiles,
    };
  }
}
