import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:samapp/utils/money_formatter.dart';
import 'package:samapp/models/debt.dart';
import 'package:samapp/services/debt_service.dart';
import 'package:samapp/screens/add_edit_debt_screen.dart';
import 'package:samapp/widgets/empty_state.dart';

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
          final allDebts = box.values.toList();
          final summary = _debtService.getDebtSummary();

          List<Debt> filteredDebts = allDebts;
          if (_currentFilter == DebtFilter.paid) {
            filteredDebts = allDebts.where((d) => d.isPaid).toList();
          } else if (_currentFilter == DebtFilter.unpaid) {
            filteredDebts = allDebts.where((d) => !d.isPaid).toList();
          }

          filteredDebts.sort((a, b) {
            if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
            return a.dueDate.compareTo(b.dueDate);
          });

          return Column(
            children: [
              _buildSummaryHeader(summary['totalOwed']!, summary['totalOwedToYou']!),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SegmentedButton<DebtFilter>(
                  segments: const [
                    ButtonSegment(value: DebtFilter.all, label: Text('All'), icon: Icon(Icons.list)),
                    ButtonSegment(value: DebtFilter.unpaid, label: Text('Unpaid'), icon: Icon(Icons.hourglass_bottom)),
                    ButtonSegment(value: DebtFilter.paid, label: Text('Paid'), icon: Icon(Icons.check_circle)),
                  ],
                  selected: {_currentFilter},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _currentFilter = newSelection.first;
                    });
                  },
                ),
              ),
              if (filteredDebts.isEmpty)
                Expanded(
                  child: EmptyStates.noDebts(context, onAdd: _navigateToAddDebt),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDebts.length,
                    itemBuilder: (context, index) {
                      final debt = filteredDebts[index];
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
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'debts_fab',
        onPressed: _navigateToAddDebt,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddDebt() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditDebtScreen()),
    );
  }

  Widget _buildSummaryHeader(double totalOwed, double totalOwedToYou) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('You Owe', totalOwed, Colors.red[300]!),
          _buildSummaryItem('Owed to You', totalOwedToYou, Colors.green[300]!),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Text(
          formatMoney(amount),
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDebtCard(BuildContext context, Debt debt) {
    final isPaid = debt.isPaid;
    final isOverdue = !isPaid && debt.dueDate.isBefore(DateTime.now());
    final isIOwe = debt.type == DebtType.iOwe;
    final cardColor = isIOwe ? Colors.red.shade300 : Colors.green.shade300;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isPaid ? Colors.grey.shade300 : cardColor, width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddEditDebtScreen(debt: debt)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isIOwe ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: isPaid ? Colors.grey : cardColor,
                size: 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.person,
                      style: TextStyle(
                        fontSize: 17, 
                        fontWeight: FontWeight.bold, 
                        color: isPaid ? Colors.grey : null,
                        decoration: isPaid ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (debt.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          debt.description,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'Due: ${DateFormat('MMM d, y').format(debt.dueDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(debt.amount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? Colors.grey : cardColor,
                      decoration: isPaid ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (isPaid)
                    const Text('Paid', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  if (isOverdue)
                    const Text('Overdue', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
