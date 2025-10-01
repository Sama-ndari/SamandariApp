import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/services/expense_service.dart';
import 'package:samapp/screens/add_edit_expense_screen.dart';
import 'package:samapp/screens/expense_summary_screen.dart';
import 'package:samapp/screens/budget_management_screen.dart';
import 'package:samapp/utils/money_formatter.dart';
import 'package:samapp/widgets/empty_state.dart';
import 'package:samapp/widgets/animated_transitions.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ExpenseService _expenseService = ExpenseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Expense>('expenses').listenable(),
        builder: (context, Box<Expense> box, _) {
          final expenses = box.values.toList().cast<Expense>();
          final spendingByCategory = _expenseService.getSpendingByCategory();

          return Column(
            children: [
              _buildChart(spendingByCategory),
              Expanded(
                child: _buildExpenseList(expenses),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'expenses_budget_fab',
            mini: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BudgetManagementScreen(),
                ),
              );
            },
            child: const Icon(Icons.account_balance_wallet),
            tooltip: 'Manage Budgets',
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 'expenses_summary_fab',
            mini: true,
            onPressed: () {
              final spendingByCategory = _expenseService.getSpendingByCategory();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExpenseSummaryScreen(spendingByCategory: spendingByCategory),
                ),
              );
            },
            child: const Icon(Icons.bar_chart),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 'expenses_fab',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditExpenseScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(Map<ExpenseCategory, double> spendingByCategory) {
    if (spendingByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: spendingByCategory.entries.map((entry) {
            return PieChartSectionData(
              color: _getCategoryColor(entry.key),
              value: entry.value,
              title: '${entry.key.toString().split('.').last.substring(0, 1).toUpperCase()}${entry.key.toString().split('.').last.substring(1)}',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return EmptyStates.noExpenses(
        context,
        onAdd: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditExpenseScreen(),
            ),
          );
        },
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            _expenseService.deleteExpense(expense.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${expense.description} deleted')),
            );
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
          leading: Icon(_getCategoryIcon(expense.category)),
          title: Text(expense.description),
          subtitle: Text(DateFormat.yMd().format(expense.date)),
          trailing: Text(formatMoney(expense.amount)),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddEditExpenseScreen(expense: expense),
              ),
            );
          },
        ),);
      },
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transportation:
        return Colors.blue;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.utilities:
        return Colors.green;
      case ExpenseCategory.healthcare:
        return Colors.red;
      case ExpenseCategory.education:
        return Colors.teal;
      case ExpenseCategory.phone:
        return Colors.cyan;
      case ExpenseCategory.social:
        return Colors.amber;
      case ExpenseCategory.family:
        return Colors.brown;
      case ExpenseCategory.other:
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.fastfood;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.shopping:
        return Icons.shopping_cart;
      case ExpenseCategory.utilities:
        return Icons.lightbulb;
      case ExpenseCategory.healthcare:
        return Icons.healing;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.phone:
        return Icons.phone;
      case ExpenseCategory.social:
        return Icons.people;
      case ExpenseCategory.family:
        return Icons.family_restroom;
      case ExpenseCategory.other:
      default:
        return Icons.money;
    }
  }
}
