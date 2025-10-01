import 'package:hive/hive.dart';
import 'package:samapp/models/water_intake.dart';

class WaterIntakeService {
  final Box<WaterIntake> _waterIntakeBox = Hive.box<WaterIntake>('water_intake');

  WaterIntake? getWaterIntakeForToday() {
    final today = DateTime.now();
    final todayWithoutTime = DateTime(today.year, today.month, today.day);
    return _waterIntakeBox.get(todayWithoutTime.toIso8601String());
  }

  Future<void> addWater(int amount) async {
    final today = DateTime.now();
    final todayWithoutTime = DateTime(today.year, today.month, today.day);
    final key = todayWithoutTime.toIso8601String();

    final existingIntake = _waterIntakeBox.get(key);
    if (existingIntake != null) {
      existingIntake.amount += amount;
      await _waterIntakeBox.put(key, existingIntake);
    } else {
      final newIntake = WaterIntake()
        ..date = todayWithoutTime
        ..amount = amount;
      await _waterIntakeBox.put(key, newIntake);
    }
  }

  Future<void> resetWaterIntake() async {
    final today = DateTime.now();
    final todayWithoutTime = DateTime(today.year, today.month, today.day);
    final key = todayWithoutTime.toIso8601String();

    final existingIntake = _waterIntakeBox.get(key);
    if (existingIntake != null) {
      existingIntake.amount = 0;
      await _waterIntakeBox.put(key, existingIntake);
    } else {
      final newIntake = WaterIntake()
        ..date = todayWithoutTime
        ..amount = 0;
      await _waterIntakeBox.put(key, newIntake);
    }
  }
}
