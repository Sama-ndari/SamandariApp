import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:samapp/utils/money_formatter.dart';
import 'package:samapp/models/debt.dart';
import 'package:samapp/services/debt_service.dart';
import 'package:samapp/screens/add_edit_debt_screen.dart';
import 'package:samapp/widgets/empty_state.dart';
import 'package:samapp/screens/debt_summary_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

enum DebtFilter { all, unpaid, paid }

class _DebtsScreenState extends State<DebtsScreen> {
  final DebtService _debtService = DebtService();
  DebtFilter _currentFilter = DebtFilter.unpaid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Debt>('debts').listenable(),
        builder: (context, Box<Debt> box, _) {
          List<Debt> debts = box.values.toList().cast<Debt>();

          // Filter debts
          if (_currentFilter == DebtFilter.paid) {
            debts = debts.where((d) => d.isPaid).toList();
          } else if (_currentFilter == DebtFilter.unpaid) {
            debts = debts.where((d) => !d.isPaid).toList();
          }

          // Sort debts: unpaid first, then by due date (earliest first)
          debts.sort((a, b) {
            if (a.isPaid != b.isPaid) {
              return a.isPaid ? 1 : -1;
            }
            return a.dueDate.compareTo(b.dueDate);
          });

          if (debts.isEmpty) {
            return EmptyStates.noDebts(
              context,
              onAdd: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddEditDebtScreen(),
                  ),
                );
              },
            );
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: SegmentedButton<DebtFilter>(
                  segments: const [
                    ButtonSegment(value: DebtFilter.all, label: Text('All')),
                    ButtonSegment(value: DebtFilter.unpaid, label: Text('Unpaid')),
                    ButtonSegment(value: DebtFilter.paid, label: Text('Paid')),
                  ],
                  selected: {_currentFilter},
                  onSelectionChanged: (Set<DebtFilter> newSelection) {
                    setState(() {
                      _currentFilter = newSelection.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              return Dismissible(
                key: Key(debt.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _debtService.deleteDebt(debt.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${debt.person} deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          _debtService.updateDebt(debt);
                        },
                      ),
                    ),
                  );
                },
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: _buildDebtCard(context, debt),
              );
            },
          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'debts_summary_fab',
            mini: true,
            onPressed: () {
              final summary = _debtService.getDebtSummary();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DebtSummaryScreen(
                    totalOwed: summary['totalOwed']!,
                    totalOwedToYou: summary['totalOwedToYou']!,
                  ),
                ),
              );
            },
            child: const Icon(Icons.info_outline),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 'debts_fab',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditDebtScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, Debt debt) {
    final isPaid = debt.isPaid;
    final isOverdue = !isPaid && debt.dueDate.isBefore(DateTime.now());
    final isIOwe = debt.type == DebtType.iOwe;
    final cardColor = isIOwe ? Colors.red : Colors.green;
    
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddEditDebtScreen(debt: debt),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            left: BorderSide(
              color: isPaid ? Colors.grey : cardColor,
              width: 5,
            ),
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isPaid
                    ? Icons.check_circle
                    : (isIOwe ? Icons.arrow_upward : Icons.arrow_downward),
                color: isPaid ? Colors.grey : cardColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            debt.person,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: isPaid ? TextDecoration.lineThrough : null,
                              color: isPaid ? Colors.grey : null,
                            ),
                          ),
                        ),
                        if (isPaid)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PAID',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      debt.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isPaid ? Colors.grey : Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Due: ${DateFormat('MMM d, y').format(debt.dueDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue
                                ? Colors.red
                                : (isPaid ? Colors.grey : Colors.grey[600]),
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'OVERDUE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatMoney(debt.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: isPaid ? TextDecoration.lineThrough : null,
                  color: isPaid ? Colors.grey : cardColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
