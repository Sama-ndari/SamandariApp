import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samapp/models/debt.dart';
import 'package:samapp/services/debt_service.dart';

class AddEditDebtScreen extends StatefulWidget {
  final Debt? debt;

  const AddEditDebtScreen({super.key, this.debt});

  @override
  State<AddEditDebtScreen> createState() => _AddEditDebtScreenState();
}

class _AddEditDebtScreenState extends State<AddEditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _debtService = DebtService();

  late String _person;
  late double _amount;
  late String _description;
  late DateTime _dueDate;
  late DebtType _type;

  @override
  void initState() {
    super.initState();
    _person = widget.debt?.person ?? '';
    _amount = widget.debt?.amount ?? 0.0;
    _description = widget.debt?.description ?? '';
    _dueDate = widget.debt?.dueDate ?? DateTime.now();
    _type = widget.debt?.type ?? DebtType.iOwe;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newDebt = Debt()
        ..id = widget.debt?.id ?? ''
        ..person = _person
        ..amount = _amount
        ..description = _description
        ..dueDate = _dueDate
        ..type = _type
        ..isPaid = widget.debt?.isPaid ?? false
        ..createdAt = widget.debt?.createdAt ?? DateTime.now();

      if (widget.debt == null) {
        _debtService.addDebt(newDebt);
      } else {
        _debtService.updateDebt(newDebt);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.debt == null ? 'Add Debt' : 'Edit Debt'),
        actions: [
          if (widget.debt != null && !widget.debt!.isPaid)
            IconButton(
              icon: const Icon(Icons.check_circle),
              color: Colors.green,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Mark as Paid'),
                    content: const Text('Mark this debt as paid?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          final paidDebt = Debt()
                            ..id = widget.debt!.id
                            ..person = widget.debt!.person
                            ..amount = widget.debt!.amount
                            ..description = widget.debt!.description
                            ..dueDate = widget.debt!.dueDate
                            ..type = widget.debt!.type
                            ..isPaid = true
                            ..createdAt = widget.debt!.createdAt;
                          _debtService.updateDebt(paidDebt);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Mark Paid', style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Mark as Paid',
            ),
          if (widget.debt != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Debt'),
                    content: const Text('Are you sure you want to delete this debt?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _debtService.deleteDebt(widget.debt!.id);
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
                initialValue: _person,
                decoration: const InputDecoration(labelText: 'Person'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a person\'s name';
                  }
                  return null;
                },
                onSaved: (value) => _person = value!,
              ),
              TextFormField(
                initialValue: _amount.toString(),
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
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DebtType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: DebtType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type == DebtType.iOwe ? 'I Owe' : 'Owed to Me'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Due Date: ${DateFormat.yMd().format(_dueDate)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dueDate = pickedDate;
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
                child: Text(widget.debt == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
