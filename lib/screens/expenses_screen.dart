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

enum ExpenseViewMode { daily, weekly, monthly, total }

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ExpenseService _expenseService = ExpenseService();
  DateTime _selectedDate = DateTime.now();
  ExpenseViewMode _viewMode = ExpenseViewMode.daily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Expense>('expenses').listenable(),
        builder: (context, Box<Expense> box, _) {
          final allExpenses = box.values.toList().cast<Expense>();
          
          // Filter expenses based on view mode
          final expenses = _filterExpensesByViewMode(allExpenses);
          
          final totalExpenses = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
          
          // Get spending by category
          final spendingByCategory = <ExpenseCategory, double>{};
          for (var expense in expenses) {
            spendingByCategory[expense.category] = 
                (spendingByCategory[expense.category] ?? 0) + expense.amount;
          }

          return Column(
            children: [
              _buildDateSelector(),
              _buildTotalExpensesCard(totalExpenses, expenses.length),
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

  List<Expense> _filterExpensesByViewMode(List<Expense> allExpenses) {
    final now = _selectedDate;
    
    switch (_viewMode) {
      case ExpenseViewMode.daily:
        return allExpenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month &&
              expense.date.day == now.day;
        }).toList();
      
      case ExpenseViewMode.weekly: {
        // Adjust to ensure Monday is the start of the week (weekday is 1)
        final daysToSubtract = now.weekday - 1;
        final weekStart = DateTime(now.year, now.month, now.day - daysToSubtract);
        final weekEnd = weekStart.add(const Duration(days: 7)); // Go up to the next Monday morning

        return allExpenses.where((expense) {
          return !expense.date.isBefore(weekStart) && expense.date.isBefore(weekEnd);
        }).toList();
      }
      
      case ExpenseViewMode.monthly:
        return allExpenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month;
        }).toList();
      
      case ExpenseViewMode.total:
        return allExpenses;
    }
  }

  String _getViewModeText() {
    switch (_viewMode) {
      case ExpenseViewMode.daily:
        return DateFormat('EEEE, MMMM d, y').format(_selectedDate);
      case ExpenseViewMode.weekly: {
        final daysToSubtract = _selectedDate.weekday - 1;
        final weekStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day - daysToSubtract);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return 'Week: ${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, y').format(weekEnd)}';
      }
      case ExpenseViewMode.monthly:
        return DateFormat('MMMM yyyy').format(_selectedDate);
      case ExpenseViewMode.total:
        return 'All Expenses';
    }
  }

  void _navigatePrevious() {
    setState(() {
      switch (_viewMode) {
        case ExpenseViewMode.daily:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case ExpenseViewMode.weekly:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case ExpenseViewMode.monthly:
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
          break;
        case ExpenseViewMode.total:
          break;
      }
    });
  }

  void _navigateNext() {
    setState(() {
      switch (_viewMode) {
        case ExpenseViewMode.daily:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
        case ExpenseViewMode.weekly:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case ExpenseViewMode.monthly:
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
          break;
        case ExpenseViewMode.total:
          break;
      }
    });
  }

  Widget _buildDateSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 600;
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: isLandscape ? 6 : 12
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: isLandscape ? 4 : 8
          ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          PopupMenuButton<ExpenseViewMode>(
            icon: const Icon(Icons.view_module),
            tooltip: 'View Mode',
            onSelected: (ExpenseViewMode mode) {
              setState(() {
                _viewMode = mode;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: ExpenseViewMode.daily,
                child: Row(
                  children: [
                    Icon(Icons.today, size: 20),
                    SizedBox(width: 12),
                    Text('Daily'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ExpenseViewMode.weekly,
                child: Row(
                  children: [
                    Icon(Icons.view_week, size: 20),
                    SizedBox(width: 12),
                    Text('Weekly'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ExpenseViewMode.monthly,
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20),
                    SizedBox(width: 12),
                    Text('Monthly'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ExpenseViewMode.total,
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, size: 20),
                    SizedBox(width: 12),
                    Text('Total'),
                  ],
                ),
              ),
            ],
          ),
          if (_viewMode != ExpenseViewMode.total) ...[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _navigatePrevious,
            ),
          ],
          Expanded(
            child: InkWell(
              onTap: _viewMode == ExpenseViewMode.total
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_viewMode != ExpenseViewMode.total)
                        const Icon(Icons.calendar_today, size: 18),
                      if (_viewMode != ExpenseViewMode.total)
                        const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _getViewModeText(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLandscape ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_viewMode != ExpenseViewMode.total) ...[
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _navigateNext,
            ),
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime.now();
                });
              },
              tooltip: 'Today',
            ),
          ],
        ],
      ),
        );
      },
    );
  }

  Widget _buildTotalExpensesCard(double total, int count) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 600;
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: isLandscape ? 6 : 12
          ),
          padding: EdgeInsets.all(isLandscape ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade600,
            Colors.green.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                'Total Expenses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: isLandscape ? 8 : 12),
          Text(
            formatMoney(total),
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscape ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isLandscape ? 4 : 6),
          Text(
            '$count ${count == 1 ? 'transaction' : 'transactions'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isLandscape ? 11 : 13,
            ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildChart(Map<ExpenseCategory, double> spendingByCategory) {
    if (spendingByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 600;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(isLandscape ? 12 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Spending by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isLandscape ? 12 : 20),
          SizedBox(
            height: isLandscape ? 180 : 280,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: spendingByCategory.entries.map((entry) {
                  final total = spendingByCategory.values.fold<double>(0, (sum, val) => sum + val);
                  final percentage = (entry.value / total * 100).toStringAsFixed(1);
                  return PieChartSectionData(
                    color: _getCategoryColor(entry.key),
                    value: entry.value,
                    title: '$percentage%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: spendingByCategory.entries.map((entry) {
              final categoryName = entry.key.toString().split('.').last;
              final formattedName = '${categoryName.substring(0, 1).toUpperCase()}${categoryName.substring(1)}';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
        );
      },
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
      padding: const EdgeInsets.only(bottom: 80), // Add padding to prevent FAB overlap
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
