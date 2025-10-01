import 'package:flutter/material.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/utils/money_formatter.dart';

class ExpenseSummaryScreen extends StatelessWidget {
  final Map<ExpenseCategory, double> spendingByCategory;

  const ExpenseSummaryScreen({super.key, required this.spendingByCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Summary'),
      ),
      body: ListView.builder(
        itemCount: spendingByCategory.length,
        itemBuilder: (context, index) {
          final category = spendingByCategory.keys.elementAt(index);
          final amount = spendingByCategory.values.elementAt(index);
          final categoryName = category.toString().split('.').last;
          final capitalizedCategoryName = categoryName[0].toUpperCase() + categoryName.substring(1);

          return ListTile(
            title: Text(capitalizedCategoryName),
            trailing: Text(formatMoney(amount)),
          );
        },
      ),
    );
  }
}
