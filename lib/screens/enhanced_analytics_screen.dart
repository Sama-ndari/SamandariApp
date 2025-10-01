import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/habit.dart';
import 'package:intl/intl.dart';
import 'package:samapp/utils/money_formatter.dart';

class EnhancedAnalyticsScreen extends StatefulWidget {
  const EnhancedAnalyticsScreen({super.key});

  @override
  State<EnhancedAnalyticsScreen> createState() => _EnhancedAnalyticsScreenState();
}

class _EnhancedAnalyticsScreenState extends State<EnhancedAnalyticsScreen> {
  String _selectedPeriod = '7days'; // 7days, 30days, 90days

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7days', child: Text('Last 7 Days')),
              const PopupMenuItem(value: '30days', child: Text('Last 30 Days')),
              const PopupMenuItem(value: '90days', child: Text('Last 90 Days')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpenseTrendChart(),
            const SizedBox(height: 24),
            _buildTaskCompletionChart(),
            const SizedBox(height: 24),
            _buildHabitCompletionChart(),
            const SizedBox(height: 24),
            _buildWeekComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTrendChart() {
    final expenseBox = Hive.box<Expense>('expenses');
    final days = _getDaysCount();
    final data = <FlSpot>[];

    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: days - i - 1));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      double dayTotal = 0;
      for (var expense in expenseBox.values) {
        if (expense.date.isAfter(dayStart) && expense.date.isBefore(dayEnd)) {
          dayTotal += expense.amount;
        }
      }

      data.add(FlSpot(i.toDouble(), dayTotal));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % (days ~/ 5) == 0) {
                            final date = DateTime.now()
                                .subtract(Duration(days: days - value.toInt() - 1));
                            return Text(
                              DateFormat('MM/dd').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCompletionChart() {
    final taskBox = Hive.box<Task>('tasks');
    final days = _getDaysCount();
    final completedData = <FlSpot>[];
    final createdData = <FlSpot>[];

    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: days - i - 1));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      int completed = 0;
      int created = 0;

      for (var task in taskBox.values) {
        if (task.completedDate != null &&
            task.completedDate!.isAfter(dayStart) &&
            task.completedDate!.isBefore(dayEnd)) {
          completed++;
        }
        if (task.createdDate.isAfter(dayStart) &&
            task.createdDate.isBefore(dayEnd)) {
          created++;
        }
      }

      completedData.add(FlSpot(i.toDouble(), completed.toDouble()));
      createdData.add(FlSpot(i.toDouble(), created.toDouble()));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLegendItem('Completed', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem('Created', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % (days ~/ 5) == 0) {
                            final date = DateTime.now()
                                .subtract(Duration(days: days - value.toInt() - 1));
                            return Text(
                              DateFormat('MM/dd').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: completedData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: createdData,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCompletionChart() {
    final habitBox = Hive.box<Habit>('habits');
    final days = _getDaysCount();
    final data = <FlSpot>[];

    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: days - i - 1));
      int completions = 0;

      for (var habit in habitBox.values) {
        if (habit.completionDates.any((d) =>
            d.year == date.year && d.month == date.month && d.day == date.day)) {
          completions++;
        }
      }

      data.add(FlSpot(i.toDouble(), completions.toDouble()));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Habit Completions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % (days ~/ 5) == 0) {
                            final date = DateTime.now()
                                .subtract(Duration(days: days - value.toInt() - 1));
                            return Text(
                              DateFormat('MM/dd').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: data
                      .map((spot) => BarChartGroupData(
                            x: spot.x.toInt(),
                            barRods: [
                              BarChartRodData(
                                toY: spot.y,
                                color: Colors.purple,
                                width: 8,
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekComparison() {
    // Compare this week vs last week
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final taskBox = Hive.box<Task>('tasks');
    final expenseBox = Hive.box<Expense>('expenses');

    int thisWeekTasks = 0;
    int lastWeekTasks = 0;
    double thisWeekExpenses = 0;
    double lastWeekExpenses = 0;

    for (var task in taskBox.values) {
      if (task.completedDate != null) {
        if (task.completedDate!.isAfter(thisWeekStart)) {
          thisWeekTasks++;
        } else if (task.completedDate!.isAfter(lastWeekStart) &&
            task.completedDate!.isBefore(thisWeekStart)) {
          lastWeekTasks++;
        }
      }
    }

    for (var expense in expenseBox.values) {
      if (expense.date.isAfter(thisWeekStart)) {
        thisWeekExpenses += expense.amount;
      } else if (expense.date.isAfter(lastWeekStart) &&
          expense.date.isBefore(thisWeekStart)) {
        lastWeekExpenses += expense.amount;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week vs Last Week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildComparisonRow(
              'Tasks Completed',
              thisWeekTasks,
              lastWeekTasks,
              Icons.check_circle,
              Colors.blue,
            ),
            const Divider(),
            _buildMoneyComparisonRow(
              'Expenses',
              thisWeekExpenses,
              lastWeekExpenses,
              Icons.attach_money,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    int thisWeek,
    int lastWeek,
    IconData icon,
    Color color) {
    final difference = thisWeek - lastWeek;
    final isPositive = difference >= 0;
    final percentChange = lastWeek == 0
        ? 0.0
        : (difference / lastWeek * 100).abs();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'This week: $thisWeek',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${percentChange.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Last week: $lastWeek',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyComparisonRow(
    String label,
    double thisWeek,
    double lastWeek,
    IconData icon,
    Color color) {
    final difference = thisWeek - lastWeek;
    final isPositive = difference >= 0;
    final percentChange = lastWeek == 0
        ? 0.0
        : (difference / lastWeek * 100).abs();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'This week: ${formatMoney(thisWeek)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${percentChange.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Last week: ${formatMoney(lastWeek)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  int _getDaysCount() {
    switch (_selectedPeriod) {
      case '7days':
        return 7;
      case '30days':
        return 30;
      case '90days':
        return 90;
      default:
        return 7;
    }
  }
}
