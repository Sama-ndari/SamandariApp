import 'package:hive/hive.dart';

part 'debt.g.dart';

@HiveType(typeId: 10)
enum DebtType {
  @HiveField(0)
  owedToMe,
  @HiveField(1)
  iOwe
}

@HiveType(typeId: 11)
class Debt extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String person;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String description;

  @HiveField(4)
  late DateTime dueDate;

  @HiveField(5)
  late DebtType type;

  @HiveField(6)
  late bool isPaid;

  @HiveField(7)
  late DateTime createdAt;
}
