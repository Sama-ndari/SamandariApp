import 'package:flutter/material.dart';
import 'package:samapp/utils/money_formatter.dart';

class DebtSummaryScreen extends StatelessWidget {
  final double totalOwed;
  final double totalOwedToYou;

  const DebtSummaryScreen({
    super.key,
    required this.totalOwed,
    required this.totalOwedToYou,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text('Total You Owe'),
                trailing: Text(
                  formatMoney(totalOwed),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text('Total Owed to You'),
                trailing: Text(
                  formatMoney(totalOwedToYou),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
