// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BackupSettingsAdapter extends TypeAdapter<BackupSettings> {
  @override
  final int typeId = 20;

  @override
  BackupSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BackupSettings()
      ..autoBackupEnabled = fields[0] as bool
      ..backupFrequencyDays = fields[1] as int
      ..lastBackupDate = fields[2] as DateTime?
      ..backupPath = fields[3] as String
      ..maxBackupFiles = fields[4] as int
      ..createdAt = fields[5] as DateTime
      ..updatedAt = fields[6] as DateTime;
  }

  @override
  void write(BinaryWriter writer, BackupSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.autoBackupEnabled)
      ..writeByte(1)
      ..write(obj.backupFrequencyDays)
      ..writeByte(2)
      ..write(obj.lastBackupDate)
      ..writeByte(3)
      ..write(obj.backupPath)
      ..writeByte(4)
      ..write(obj.maxBackupFiles)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
