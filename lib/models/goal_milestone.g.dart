// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_milestone.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalMilestoneAdapter extends TypeAdapter<GoalMilestone> {
  @override
  final int typeId = 22;

  @override
  GoalMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalMilestone()
      ..id = fields[0] as String
      ..goalId = fields[1] as String
      ..title = fields[2] as String
      ..description = fields[3] as String
      ..targetAmount = fields[4] as double
      ..isCompleted = fields[5] as bool
      ..completedAt = fields[6] as DateTime?
      ..createdAt = fields[7] as DateTime
      ..order = fields[8] as int;
  }

  @override
  void write(BinaryWriter writer, GoalMilestone obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.goalId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.targetAmount)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
