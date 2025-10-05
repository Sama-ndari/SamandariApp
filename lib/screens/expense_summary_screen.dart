import 'package:flutter/material.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/utils/money_formatter.dart';

class ExpenseSummaryScreen extends StatelessWidget {
  final Map<ExpenseCategory, double> spendingByCategory;

  const ExpenseSummaryScreen({super.key, required this.spendingByCategory});

  @override
  Widget build(BuildContext context) {
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
          _buildTotalCard(context, totalSpending),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
}
