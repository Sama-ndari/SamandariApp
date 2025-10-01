import 'package:hive/hive.dart';
import 'package:samapp/models/expense.dart';
import 'package:uuid/uuid.dart';

class ExpenseService {
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');
  final _uuid = const Uuid();

  // Get all expenses
  List<Expense> getAllExpenses() {
    return _expenseBox.values.toList();
  }

  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    expense.id = _uuid.v4();
    await _expenseBox.put(expense.id, expense);
  }

  // Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  // Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    await _expenseBox.delete(expenseId);
  }

  // Get expenses by category
  Map<ExpenseCategory, double> getSpendingByCategory() {
    final Map<ExpenseCategory, double> spendingMap = {};
    for (final expense in getAllExpenses()) {
      spendingMap.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return spendingMap;
  }
}
