import 'package:flutter/material.dart';
import 'package:samapp/services/auto_backup_service.dart';
import 'package:samapp/models/backup_settings.dart';
import 'package:intl/intl.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  final AutoBackupService _autoBackupService = AutoBackupService();
  late BackupSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _settings = _autoBackupService.getSettings();
      _isLoading = false;
    });
  }

  Future<void> _toggleAutoBackup(bool value) async {
    if (value) {
      await _autoBackupService.enableAutoBackup(
        frequencyDays: _settings?.backupFrequencyDays ?? 7,
      );
    } else {
      await _autoBackupService.disableAutoBackup();
    }
    await _loadSettings();
  }

  Future<void> _updateFrequency(int days) async {
    if (_settings != null) {
      _settings!.backupFrequencyDays = days;
      await _autoBackupService.updateSettings(_settings!);
      await _loadSettings();
    }
  }

  Future<void> _updateMaxFiles(int count) async {
    if (_settings != null) {
      _settings!.maxBackupFiles = count;
      await _autoBackupService.updateSettings(_settings!);
      await _loadSettings();
    }
  }

  Future<void> _performManualBackup() async {
    setState(() => _isLoading = true);
    try {
      final filePath = await _autoBackupService.performAutoBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(filePath != null
                ? 'Backup created successfully!'
                : 'Backup not needed yet'),
            backgroundColor: filePath != null ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      await _loadSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Auto Backup Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_settings == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Auto Backup Settings')),
        body: const Center(child: Text('Failed to load settings')),
      );
    }

    final status = _autoBackupService.getBackupStatus();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Backup Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            color: _settings!.autoBackupEnabled
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _settings!.autoBackupEnabled
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _settings!.autoBackupEnabled
                            ? Colors.green
                            : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _settings!.autoBackupEnabled
                            ? 'Auto Backup Enabled'
                            : 'Auto Backup Disabled',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_settings!.autoBackupEnabled) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Last Backup',
                      status['lastBackup'] != null
                          ? DateFormat('MMM dd, yyyy HH:mm')
                              .format(status['lastBackup'])
                          : 'Never',
                    ),
                    _buildInfoRow(
                      'Next Backup',
                      status['nextBackup'] != null
                          ? DateFormat('MMM dd, yyyy')
                              .format(status['nextBackup'])
                          : 'Soon',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Enable/Disable Switch
          SwitchListTile(
            title: const Text('Enable Auto Backup'),
            subtitle: const Text('Automatically backup your data'),
            value: _settings!.autoBackupEnabled,
            onChanged: _toggleAutoBackup,
          ),
          const Divider(),

          // Frequency Selection
          const ListTile(
            title: Text(
              'Backup Frequency',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<int>(
            title: const Text('Daily'),
            subtitle: const Text('Backup every day'),
            value: 1,
            groupValue: _settings!.backupFrequencyDays,
            onChanged: _settings!.autoBackupEnabled
                ? (value) => _updateFrequency(value!)
                : null,
          ),
          RadioListTile<int>(
            title: const Text('Weekly'),
            subtitle: const Text('Backup every 7 days'),
            value: 7,
            groupValue: _settings!.backupFrequencyDays,
            onChanged: _settings!.autoBackupEnabled
                ? (value) => _updateFrequency(value!)
                : null,
          ),
          RadioListTile<int>(
            title: const Text('Monthly'),
            subtitle: const Text('Backup every 30 days'),
            value: 30,
            groupValue: _settings!.backupFrequencyDays,
            onChanged: _settings!.autoBackupEnabled
                ? (value) => _updateFrequency(value!)
                : null,
          ),
          const Divider(),

          // Max Files Selection
          const ListTile(
            title: Text(
              'Keep Last N Backups',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Older backups will be deleted automatically'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _settings!.maxBackupFiles.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '${_settings!.maxBackupFiles} backups',
                    onChanged: _settings!.autoBackupEnabled
                        ? (value) => _updateMaxFiles(value.toInt())
                        : null,
                  ),
                ),
                Text(
                  '${_settings!.maxBackupFiles}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Manual Backup Button
          ElevatedButton.icon(
            onPressed: _performManualBackup,
            icon: const Icon(Icons.backup),
            label: const Text('Create Backup Now'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
          const SizedBox(height: 16),

          // Info Card
          Card(
            color: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Backup Information',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Backups are saved to Downloads folder\n'
                    '• File format: samandari_backup_YYYYMMDD_HHMMSS.json\n'
                    '• Includes all your data (tasks, expenses, notes, etc.)\n'
                    '• Old backups are cleaned automatically',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
