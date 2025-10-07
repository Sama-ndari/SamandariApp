// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legacy_capsule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LegacyCapsuleAdapter extends TypeAdapter<LegacyCapsule> {
  @override
  final int typeId = 23;

  @override
  LegacyCapsule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LegacyCapsule(
      content: fields[1] as String,
      creationDate: fields[2] as DateTime,
      openDate: fields[3] as DateTime,
      recipientName: fields[4] as String?,
    )
      ..id = fields[0] as String
      ..isOpened = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, LegacyCapsule obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.creationDate)
      ..writeByte(3)
      ..write(obj.openDate)
      ..writeByte(4)
      ..write(obj.recipientName)
      ..writeByte(5)
      ..write(obj.isOpened);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegacyCapsuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
