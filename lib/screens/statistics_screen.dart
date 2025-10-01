import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:samapp/services/statistics_service.dart';
import 'package:samapp/models/expense.dart';
import 'package:intl/intl.dart';
import 'package:samapp/utils/money_formatter.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statsService = StatisticsService();
  String _selectedPeriod = 'week'; // 'week' or 'month'

  @override
  Widget build(BuildContext context) {
    final stats = _selectedPeriod == 'week'
        ? _statsService.getWeeklyStats()
        : _statsService.getMonthlyStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'week', label: Text('Week')),
              ButtonSegment(value: 'month', label: Text('Month')),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedPeriod = newSelection.first;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTasksSection(stats['tasks']),
            const SizedBox(height: 24),
            _buildExpensesSection(stats),
            const SizedBox(height: 24),
            _buildHabitsSection(stats['habits']),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection(Map<String, dynamic> taskStats) {
    final total = taskStats['total'] as int;
    final completed = taskStats['completed'] as int;
    final pending = taskStats['pending'] as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', total.toString(), Colors.blue),
                _buildStatItem('Completed', completed.toString(), Colors.green),
                _buildStatItem('Pending', pending.toString(), Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            if (total > 0)
              Column(
                children: [
                  Text(
                    'Completion Rate: ${taskStats['completionRate']}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: completed / total,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesSection(Map<String, dynamic> stats) {
    final totalExpenses = stats['expenses'] as double;
    final expensesByCategory = _selectedPeriod == 'month'
        ? stats['expensesByCategory'] as Map<ExpenseCategory, double>
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ${formatMoney(totalExpenses)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (expensesByCategory != null && _selectedPeriod == 'month') ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: _buildExpensePieChart(expensesByCategory),
              ),
              const SizedBox(height: 16),
              _buildExpenseLegend(expensesByCategory),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpensePieChart(Map<ExpenseCategory, double> data) {
    final nonZeroData = Map.fromEntries(
      data.entries.where((entry) => entry.value > 0),
    );

    if (nonZeroData.isEmpty) {
      return const Center(child: Text('No expenses this month'));
    }

    return PieChart(
      PieChartData(
        sections: nonZeroData.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title: '${(entry.value / data.values.fold(0.0, (a, b) => a + b) * 100).toStringAsFixed(1)}%',
            color: _getCategoryColor(entry.key),
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildExpenseLegend(Map<ExpenseCategory, double> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.where((e) => e.value > 0).map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getCategoryColor(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${_getCategoryName(entry.key)}: ${formatMoney(entry.value)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHabitsSection(Map<String, dynamic> habitStats) {
    final totalHabits = habitStats['totalHabits'] as int;
    final totalCompletions = habitStats['totalCompletions'] as int;
    final averagePerDay = (habitStats['averagePerDay'] as double).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habits',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Habits', totalHabits.toString(), Colors.purple),
                _buildStatItem('Completions', totalCompletions.toString(), Colors.green),
                _buildStatItem('Avg/Day', averagePerDay, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
        return Colors.teal;
      case ExpenseCategory.healthcare:
        return Colors.red;
      case ExpenseCategory.education:
        return Colors.indigo;
      case ExpenseCategory.phone:
        return Colors.cyan;
      case ExpenseCategory.social:
        return Colors.amber;
      case ExpenseCategory.family:
        return Colors.brown;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  String _getCategoryName(ExpenseCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }
}
