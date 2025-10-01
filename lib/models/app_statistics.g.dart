// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppStatisticsAdapter extends TypeAdapter<AppStatistics> {
  @override
  final int typeId = 19;

  @override
  AppStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppStatistics()
      ..id = fields[0] as String
      ..date = fields[1] as DateTime
      ..tasksCompleted = fields[2] as int
      ..habitsCompleted = fields[3] as int
      ..totalExpenses = fields[4] as double
      ..waterGlasses = fields[5] as int
      ..notesCreated = fields[6] as int
      ..goalsAchieved = fields[7] as int
      ..createdAt = fields[8] as DateTime;
  }

  @override
  void write(BinaryWriter writer, AppStatistics obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.tasksCompleted)
      ..writeByte(3)
      ..write(obj.habitsCompleted)
      ..writeByte(4)
      ..write(obj.totalExpenses)
      ..writeByte(5)
      ..write(obj.waterGlasses)
      ..writeByte(6)
      ..write(obj.notesCreated)
      ..writeByte(7)
      ..write(obj.goalsAchieved)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
