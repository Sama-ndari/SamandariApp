import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/budget.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/services/budget_service.dart';
import 'package:samapp/utils/money_formatter.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  final BudgetService _budgetService = BudgetService();

  void _showAddBudgetDialog(BuildContext context, {Budget? budget}) {
    ExpenseCategory? selectedCategory = budget?.category;
    final amountController = TextEditingController(
      text: budget?.monthlyLimit.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(budget == null ? 'Add Budget' : 'Edit Budget'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ExpenseCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ExpenseCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryName(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) => value == null ? 'Select category' : null,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Limit (FBu)',
                    prefixText: 'FBu ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedCategory != null && amountController.text.isNotEmpty) {
                final amount = double.tryParse(amountController.text) ?? 0;
                
                if (budget == null) {
                  _budgetService.setBudget(selectedCategory!, amount);
                } else {
                  // Update existing budget
                  budget.category = selectedCategory!;
                  budget.monthlyLimit = amount;
                  budget.save();
                }
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(budget == null ? 'Budget created' : 'Budget updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(budget == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(ExpenseCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Budget>('budgets').listenable(),
        builder: (context, Box<Budget> budgetBox, _) {
          final budgets = budgetBox.values.toList();
          
          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set monthly limits for your expense categories',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final spending = _budgetService.getMonthlySpending(budget.category);
              final percentage = (spending / budget.monthlyLimit * 100).clamp(0, 100);
              
              Color progressColor = Colors.green;
              if (percentage > 90) {
                progressColor = Colors.red;
              } else if (percentage > 75) {
                progressColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _showAddBudgetDialog(context, budget: budget),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getCategoryName(budget.category),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Budget'),
                                    content: const Text('Remove this budget limit?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _budgetService.deleteBudget(budget.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatMoney(spending),
                              style: TextStyle(
                                fontSize: 16,
                                color: progressColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'of ${formatMoney(budget.monthlyLimit)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[300],
                          color: progressColor,
                          minHeight: 8,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(0)}% used',
                          style: TextStyle(
                            fontSize: 12,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
