import 'package:hive/hive.dart';

part 'water_intake.g.dart';

@HiveType(typeId: 12)
class WaterIntake extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late int amount;
}
