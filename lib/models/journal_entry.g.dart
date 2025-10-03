// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 9;

  @override
  JournalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntry()
      ..id = fields[0] as String
      ..content = fields[1] as String
      ..date = fields[2] as DateTime
      ..mood = fields[3] as Mood
      ..tags = (fields[4] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodAdapter extends TypeAdapter<Mood> {
  @override
  final int typeId = 8;

  @override
  Mood read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Mood.happy;
      case 1:
        return Mood.sad;
      case 2:
        return Mood.neutral;
      case 3:
        return Mood.excited;
      case 4:
        return Mood.calm;
      case 5:
        return Mood.anxious;
      case 6:
        return Mood.grateful;
      case 7:
        return Mood.angry;
      case 8:
        return Mood.loved;
      case 9:
        return Mood.peaceful;
      case 10:
        return Mood.stressed;
      case 11:
        return Mood.energetic;
      case 12:
        return Mood.tired;
      case 13:
        return Mood.hopeful;
      case 14:
        return Mood.lonely;
      case 15:
        return Mood.confused;
      case 16:
        return Mood.proud;
      case 17:
        return Mood.disappointed;
      case 18:
        return Mood.content;
      case 19:
        return Mood.inspired;
      default:
        return Mood.happy;
    }
  }

  @override
  void write(BinaryWriter writer, Mood obj) {
    switch (obj) {
      case Mood.happy:
        writer.writeByte(0);
        break;
      case Mood.sad:
        writer.writeByte(1);
        break;
      case Mood.neutral:
        writer.writeByte(2);
        break;
      case Mood.excited:
        writer.writeByte(3);
        break;
      case Mood.calm:
        writer.writeByte(4);
        break;
      case Mood.anxious:
        writer.writeByte(5);
        break;
      case Mood.grateful:
        writer.writeByte(6);
        break;
      case Mood.angry:
        writer.writeByte(7);
        break;
      case Mood.loved:
        writer.writeByte(8);
        break;
      case Mood.peaceful:
        writer.writeByte(9);
        break;
      case Mood.stressed:
        writer.writeByte(10);
        break;
      case Mood.energetic:
        writer.writeByte(11);
        break;
      case Mood.tired:
        writer.writeByte(12);
        break;
      case Mood.hopeful:
        writer.writeByte(13);
        break;
      case Mood.lonely:
        writer.writeByte(14);
        break;
      case Mood.confused:
        writer.writeByte(15);
        break;
      case Mood.proud:
        writer.writeByte(16);
        break;
      case Mood.disappointed:
        writer.writeByte(17);
        break;
      case Mood.content:
        writer.writeByte(18);
        break;
      case Mood.inspired:
        writer.writeByte(19);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
