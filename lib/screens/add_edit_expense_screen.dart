import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/services/expense_service.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  String _formatCategoryName(ExpenseCategory category) {
    String name = category.toString().split('.').last;
    // Handle camelCase by inserting a space before capital letters
    name = name.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (match) => ' ${match.group(0)}');
    return name[0].toUpperCase() + name.substring(1);
  }

  final _formKey = GlobalKey<FormState>();
  final _expenseService = ExpenseService();

  late String _description;
  late double _amount;
  late ExpenseCategory _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _description = widget.expense?.description ?? '';
    _amount = widget.expense?.amount ?? 0.0;
    _category = widget.expense?.category ?? ExpenseCategory.other;
    _date = widget.expense?.date ?? DateTime.now();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newExpense = Expense()
        ..id = widget.expense?.id ?? ''
        ..description = _description
        ..amount = _amount
        ..category = _category
        ..date = _date
        ..createdAt = widget.expense?.createdAt ?? DateTime.now();

      if (widget.expense == null) {
        _expenseService.addExpense(newExpense);
      } else {
        _expenseService.updateExpense(newExpense);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
        actions: [
          if (widget.expense != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Expense'),
                    content: const Text('Are you sure you want to delete this expense?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _expenseService.deleteExpense(widget.expense!.id);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: _amount == 0.0 && widget.expense == null ? '0' : _amount.toString(),
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpenseCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ExpenseCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_formatCategoryName(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${DateFormat.yMd().format(_date)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _date = pickedDate;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.expense == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
