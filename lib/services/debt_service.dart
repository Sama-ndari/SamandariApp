import 'package:hive/hive.dart';
import 'package:samapp/models/debt.dart';
import 'package:uuid/uuid.dart';

class DebtService {
  final Box<Debt> _debtBox = Hive.box<Debt>('debts');
  final _uuid = const Uuid();

  // Get all debts
  List<Debt> getAllDebts() {
    return _debtBox.values.toList();
  }

  // Add a new debt
  Future<void> addDebt(Debt debt) async {
    debt.id = _uuid.v4();
    await _debtBox.put(debt.id, debt);
  }

  // Update an existing debt
  Future<void> updateDebt(Debt debt) async {
    await _debtBox.put(debt.id, debt);
  }

  // Delete a debt
  Future<void> deleteDebt(String debtId) async {
    await _debtBox.delete(debtId);
  }

  // Get debt summary
  Map<String, double> getDebtSummary() {
    double totalOwed = 0;
    double totalOwedToYou = 0;

    for (var debt in _debtBox.values) {
      if (debt.type == DebtType.iOwe) {
        totalOwed += debt.amount;
      } else {
        totalOwedToYou += debt.amount;
      }
    }

    return {
      'totalOwed': totalOwed,
      'totalOwedToYou': totalOwedToYou,
    };
  }
}
