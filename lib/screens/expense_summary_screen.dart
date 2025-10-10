import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/utils/money_formatter.dart';

enum ExpenseViewMode { daily, weekly, monthly, total }

class ExpenseSummaryScreen extends StatefulWidget {
  const ExpenseSummaryScreen({super.key});

  @override
  State<ExpenseSummaryScreen> createState() => _ExpenseSummaryScreenState();
}

class _ExpenseSummaryScreenState extends State<ExpenseSummaryScreen> {
  DateTime _selectedDate = DateTime.now();
  ExpenseViewMode _viewMode = ExpenseViewMode.total;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Expense>('expenses').listenable(),
      builder: (context, Box<Expense> box, _) {
        final allExpenses = box.values.toList();
        final expenses = _filterExpensesByViewMode(allExpenses);

        final spendingByCategory = <ExpenseCategory, double>{};
        for (var expense in expenses) {
          spendingByCategory[expense.category] = 
              (spendingByCategory[expense.category] ?? 0) + expense.amount;
        }

        final totalSpending = spendingByCategory.values.fold(0.0, (sum, amount) => sum + amount);
        final sortedCategories = spendingByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense Summary'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          body: Column(
            children: [
              _buildDateSelector(),
              _buildTotalCard(context, totalSpending),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final entry = sortedCategories[index];
                    final category = entry.key;
                    final amount = entry.value;
                    final percentage = totalSpending > 0 ? amount / totalSpending : 0.0;
                    final categoryName = category.toString().split('.').last;
                    final capitalizedCategoryName =
                        '${categoryName[0].toUpperCase()}${categoryName.substring(1)}';

                    return _buildCategoryCard(
                      context,
                      category,
                      capitalizedCategoryName,
                      amount,
                      percentage,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalCard(BuildContext context, double totalSpending) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Spending',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(totalSpending),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    ExpenseCategory category,
    String categoryName,
    double amount,
    double percentage,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: _getCategoryColor(category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  formatMoney(amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(category)),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
        final daysToSubtract = now.weekday - 1;
        final weekStart = DateTime(now.year, now.month, now.day - daysToSubtract);
        final weekEnd = weekStart.add(const Duration(days: 7));

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
}
