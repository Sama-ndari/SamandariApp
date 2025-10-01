import 'package:hive/hive.dart';

part 'backup_settings.g.dart';

@HiveType(typeId: 20)
class BackupSettings extends HiveObject {
  @HiveField(0)
  late bool autoBackupEnabled;

  @HiveField(1)
  late int backupFrequencyDays; // 1 = daily, 7 = weekly, 30 = monthly

  @HiveField(2)
  late DateTime? lastBackupDate;

  @HiveField(3)
  late String backupPath;

  @HiveField(4)
  late int maxBackupFiles; // Keep last N backups

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late DateTime updatedAt;
}
