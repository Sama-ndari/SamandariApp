// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 4;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense()
      ..id = fields[0] as String
      ..description = fields[1] as String
      ..amount = fields[2] as double
      ..category = fields[3] as ExpenseCategory
      ..date = fields[4] as DateTime
      ..createdAt = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 3;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.food;
      case 1:
        return ExpenseCategory.transportation;
      case 2:
        return ExpenseCategory.entertainment;
      case 3:
        return ExpenseCategory.shopping;
      case 4:
        return ExpenseCategory.utilities;
      case 5:
        return ExpenseCategory.healthcare;
      case 6:
        return ExpenseCategory.education;
      case 7:
        return ExpenseCategory.phone;
      case 8:
        return ExpenseCategory.social;
      case 9:
        return ExpenseCategory.family;
      case 10:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.food;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.food:
        writer.writeByte(0);
        break;
      case ExpenseCategory.transportation:
        writer.writeByte(1);
        break;
      case ExpenseCategory.entertainment:
        writer.writeByte(2);
        break;
      case ExpenseCategory.shopping:
        writer.writeByte(3);
        break;
      case ExpenseCategory.utilities:
        writer.writeByte(4);
        break;
      case ExpenseCategory.healthcare:
        writer.writeByte(5);
        break;
      case ExpenseCategory.education:
        writer.writeByte(6);
        break;
      case ExpenseCategory.phone:
        writer.writeByte(7);
        break;
      case ExpenseCategory.social:
        writer.writeByte(8);
        break;
      case ExpenseCategory.family:
        writer.writeByte(9);
        break;
      case ExpenseCategory.other:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
