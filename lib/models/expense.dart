import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 3)
enum ExpenseCategory {
  @HiveField(0)
  food,
  @HiveField(1)
  transportation,
  @HiveField(2)
  entertainment,
  @HiveField(3)
  shopping,
  @HiveField(4)
  utilities,
  @HiveField(5)
  healthcare,
  @HiveField(6)
  education,
  @HiveField(7)
  phone,
  @HiveField(8)
  social,
  @HiveField(9)
  family,
  @HiveField(10)
  other,
  @HiveField(11)
  personalCare,
  @HiveField(12)
  lifestyle
}

@HiveType(typeId: 4)
class Expense extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late ExpenseCategory category;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late DateTime createdAt;
}
