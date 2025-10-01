// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 18;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..description = fields[2] as String
      ..type = fields[3] as ReminderType
      ..reminderTime = fields[4] as DateTime
      ..isEnabled = fields[5] as bool
      ..relatedItemId = fields[6] as String
      ..createdAt = fields[7] as DateTime
      ..isRecurring = fields[8] as bool
      ..recurringPattern = fields[9] as String?;
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.reminderTime)
      ..writeByte(5)
      ..write(obj.isEnabled)
      ..writeByte(6)
      ..write(obj.relatedItemId)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isRecurring)
      ..writeByte(9)
      ..write(obj.recurringPattern);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderTypeAdapter extends TypeAdapter<ReminderType> {
  @override
  final int typeId = 17;

  @override
  ReminderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderType.task;
      case 1:
        return ReminderType.habit;
      case 2:
        return ReminderType.water;
      case 3:
        return ReminderType.debt;
      case 4:
        return ReminderType.goal;
      default:
        return ReminderType.task;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderType obj) {
    switch (obj) {
      case ReminderType.task:
        writer.writeByte(0);
        break;
      case ReminderType.habit:
        writer.writeByte(1);
        break;
      case ReminderType.water:
        writer.writeByte(2);
        break;
      case ReminderType.debt:
        writer.writeByte(3);
        break;
      case ReminderType.goal:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
