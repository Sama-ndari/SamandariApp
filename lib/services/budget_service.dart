import 'package:hive/hive.dart';
import 'package:samapp/models/budget.dart';
import 'package:samapp/models/expense.dart';
import 'package:uuid/uuid.dart';

class BudgetService {
  final Box<Budget> _budgetBox = Hive.box<Budget>('budgets');
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');
  final Uuid _uuid = const Uuid();

  Future<void> setBudget(ExpenseCategory category, double monthlyLimit) async {
    // Check if budget exists for this category
    Budget? existingBudget;
    for (var budget in _budgetBox.values) {
      if (budget.category == category) {
        existingBudget = budget;
        break;
      }
    }

    if (existingBudget != null) {
      existingBudget.monthlyLimit = monthlyLimit;
      existingBudget.updatedAt = DateTime.now();
      await existingBudget.save();
    } else {
      final budget = Budget()
        ..id = _uuid.v4()
        ..category = category
        ..monthlyLimit = monthlyLimit
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await _budgetBox.put(budget.id, budget);
    }
  }

  Budget? getBudget(ExpenseCategory category) {
    for (var budget in _budgetBox.values) {
      if (budget.category == category) {
        return budget;
      }
    }
    return null;
  }

  double getMonthlySpending(ExpenseCategory category) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    double total = 0;
    for (var expense in _expenseBox.values) {
      if (expense.category == category &&
          expense.date.isAfter(startOfMonth) &&
          expense.date.isBefore(endOfMonth)) {
        total += expense.amount;
      }
    }
    return total;
  }

  Map<ExpenseCategory, double> getAllMonthlySpending() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    Map<ExpenseCategory, double> spending = {};
    for (var category in ExpenseCategory.values) {
      spending[category] = 0;
    }

    for (var expense in _expenseBox.values) {
      if (expense.date.isAfter(startOfMonth) &&
          expense.date.isBefore(endOfMonth)) {
        spending[expense.category] = (spending[expense.category] ?? 0) + expense.amount;
      }
    }
    return spending;
  }

  bool isOverBudget(ExpenseCategory category) {
    final budget = getBudget(category);
    if (budget == null) return false;
    
    final spending = getMonthlySpending(category);
    return spending > budget.monthlyLimit;
  }

  double getBudgetPercentage(ExpenseCategory category) {
    final budget = getBudget(category);
    if (budget == null) return 0;
    
    final spending = getMonthlySpending(category);
    return (spending / budget.monthlyLimit * 100).clamp(0, 100);
  }

  List<Budget> getAllBudgets() {
    return _budgetBox.values.toList();
  }

  Future<void> deleteBudget(String id) async {
    await _budgetBox.delete(id);
  }
}
