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

class _DebtsScreenState extends State<DebtsScreen> {
  final DebtService _debtService = DebtService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Debt>('debts').listenable(),
        builder: (context, Box<Debt> box, _) {
          final debts = box.values.toList().cast<Debt>();
          
          // Sort debts: unpaid first, then by due date (earliest first)
          debts.sort((a, b) {
            // Unpaid debts come first
            if (a.isPaid != b.isPaid) {
              return a.isPaid ? 1 : -1;
            }
            // Then sort by due date
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
          return ListView.builder(
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              final isPaid = debt.isPaid;
              
              // Choose icon based on paid status and type
              IconData icon;
              Color iconColor;
              
              if (isPaid) {
                icon = Icons.check_circle;
                iconColor = Colors.grey;
              } else {
                if (debt.type == DebtType.iOwe) {
                  icon = Icons.arrow_upward;
                  iconColor = Colors.red;
                } else {
                  icon = Icons.arrow_downward;
                  iconColor = Colors.green;
                }
              }
              
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
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isPaid ? Colors.grey[100] : null,
                  child: ListTile(
                  leading: Icon(icon, color: iconColor, size: 32),
                  title: Row(
                    children: [
                      Text(
                        debt.person,
                        style: TextStyle(
                          decoration: isPaid ? TextDecoration.lineThrough : null,
                          color: isPaid ? Colors.grey : null,
                        ),
                      ),
                      if (isPaid) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'PAID',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.description,
                        style: TextStyle(
                          color: isPaid ? Colors.grey : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${DateFormat.yMMMd().format(debt.dueDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPaid 
                              ? Colors.grey 
                              : (debt.dueDate.isBefore(DateTime.now()) 
                                  ? Colors.red 
                                  : Colors.grey[600]),
                          fontWeight: debt.dueDate.isBefore(DateTime.now()) && !isPaid
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    formatMoney(debt.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: isPaid ? TextDecoration.lineThrough : null,
                      color: isPaid ? Colors.grey : (debt.type == DebtType.iOwe ? Colors.red : Colors.green),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditDebtScreen(debt: debt),
                      ),
                    );
                  },
                ), // End ListTile
              ), // End Card
            );
            },
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
}
