import 'package:hive/hive.dart';
import 'package:samapp/models/expense.dart';

part 'budget.g.dart';

@HiveType(typeId: 16)
class Budget extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late ExpenseCategory category;

  @HiveField(2)
  late double monthlyLimit;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late DateTime updatedAt;
}
