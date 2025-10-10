import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:samapp/models/expense.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/habit.dart';
import 'package:intl/intl.dart';
import 'package:samapp/utils/money_formatter.dart';
import 'package:samapp/utils/date_range_utils.dart';
import 'package:samapp/services/habit_analytics_service.dart';

class EnhancedAnalyticsScreen extends StatefulWidget {
  const EnhancedAnalyticsScreen({super.key});

  @override
  State<EnhancedAnalyticsScreen> createState() => _EnhancedAnalyticsScreenState();
}

class _EnhancedAnalyticsScreenState extends State<EnhancedAnalyticsScreen> {
  String _selectedPeriod = 'week'; // week, month, quarter

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
              const PopupMenuItem(value: 'week', child: Text('This Week vs. Last Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month vs. Last Month')),
              const PopupMenuItem(value: 'quarter', child: Text('This Quarter vs. Last Quarter')),
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
            _buildHabitCompletionChart(),
            const SizedBox(height: 24),
            _buildComparisonCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTrendChart() {
    final expenseBox = Hive.box<Expense>('expenses');
    final dateRange = _getDateRange();
    final days = dateRange.end.difference(dateRange.start).inDays;
    final data = <FlSpot>[];

    for (int i = 0; i < days; i++) {
      final date = dateRange.start.add(Duration(days: i));
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
            const Text('Expense Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10)))),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % (days ~/ 5) == 0) {
                            final date = _getDateRange().start.add(Duration(days: value.toInt()));
                            return Text(DateFormat('MM/dd').format(date), style: const TextStyle(fontSize: 10));
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
                    LineChartBarData(spots: data, isCurved: true, color: Colors.green, barWidth: 3, dotData: FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1))),
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
    if (habitBox.values.isEmpty) return const SizedBox.shrink();

    final dateRange = _getDateRange();
    final days = dateRange.end.difference(dateRange.start).inDays;
    if (days < 0) return const SizedBox.shrink();

    final data = <FlSpot>[];

    for (int i = 0; i <= days; i++) {
      final date = dateRange.start.add(Duration(days: i));
      double cumulativeAdherence = 0;
      int habitCount = 0;

      for (var habit in habitBox.values) {
        final analytics = HabitAnalytics(habit);
        // THIS IS THE KEY LINE:
        // It calculates adherence from the habit's creation date up to the current day on the chart.
        final adherenceForDate = analytics.getAdherenceForPeriod(habit.createdAt, date);
        cumulativeAdherence += adherenceForDate;
        habitCount++;
      }

      // The average of all habits' cumulative adherence up to that day.
      final avgAdherence = habitCount > 0 ? (cumulativeAdherence / habitCount) * 100 : 0.0;
      data.add(FlSpot(i.toDouble(), avgAdherence.clamp(0, 100)));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Habit Adherence Rate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)))),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % (days ~/ 5) == 0) {
                            final date = _getDateRange().start.add(Duration(days: value.toInt()));
                            return Text(DateFormat('MM/dd').format(date), style: const TextStyle(fontSize: 10));
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
                    LineChartBarData(spots: data, isCurved: true, color: Colors.purple, barWidth: 3, dotData: FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.purple.withOpacity(0.1))),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard() {
    final now = DateTime.now();
    DateRange currentPeriod;
    DateRange previousPeriod;
    String title;

    switch (_selectedPeriod) {
      case 'month':
        currentPeriod = DateRangeUtils.thisMonth(now);
        previousPeriod = DateRangeUtils.lastMonth(now);
        title = 'This Month vs. Last Month';
        break;
      case 'quarter':
        currentPeriod = DateRangeUtils.thisQuarter(now);
        previousPeriod = DateRangeUtils.lastQuarter(now);
        title = 'This Quarter vs. Last Quarter';
        break;
      case 'week':
      default:
        currentPeriod = DateRangeUtils.thisWeek(now);
        previousPeriod = DateRangeUtils.lastWeek(now);
        title = 'This Week vs. Last Week';
        break;
    }

    final taskBox = Hive.box<Task>('tasks');
    final expenseBox = Hive.box<Expense>('expenses');
    final habitBox = Hive.box<Habit>('habits');

    final currentTasks = taskBox.values.where((t) => t.completedDate != null && currentPeriod.contains(t.completedDate!)).length;
    final previousTasks = taskBox.values.where((t) => t.completedDate != null && previousPeriod.contains(t.completedDate!)).length;

    final currentExpenses = expenseBox.values.where((e) => currentPeriod.contains(e.date)).fold<double>(0, (sum, e) => sum + e.amount);
    final previousExpenses = expenseBox.values.where((e) => previousPeriod.contains(e.date)).fold<double>(0, (sum, e) => sum + e.amount);

    double currentHabitAdherence = 0;
    double previousHabitAdherence = 0;
    int currentHabitCount = 0;
    int previousHabitCount = 0;

    for (var habit in habitBox.values) {
      final analytics = HabitAnalytics(habit);
      final currentAdherence = analytics.getAdherenceForPeriod(currentPeriod.start, currentPeriod.end);
      if (currentAdherence > 0) {
        currentHabitAdherence += currentAdherence;
        currentHabitCount++;
      }

      final previousAdherence = analytics.getAdherenceForPeriod(previousPeriod.start, previousPeriod.end);
      if (previousAdherence > 0) {
        previousHabitAdherence += previousAdherence;
        previousHabitCount++;
      }
    }

    final avgCurrentAdherence = currentHabitCount > 0 ? (currentHabitAdherence / currentHabitCount) * 100 : 0.0;
    final avgPreviousAdherence = previousHabitCount > 0 ? (previousHabitAdherence / previousHabitCount) * 100 : 0.0;


    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildComparisonRow('Tasks Completed', currentTasks.toDouble(), previousTasks.toDouble(), Icons.check_circle, Colors.blue),
            const Divider(),
             _buildComparisonRow('Habit Adherence', avgCurrentAdherence, avgPreviousAdherence, Icons.repeat, Colors.purple, isPercentage: true),
            const Divider(),
            _buildComparisonRow('Expenses', currentExpenses, previousExpenses, Icons.attach_money, Colors.green, isMoney: true),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, double current, double previous, IconData icon, Color color, {bool isMoney = false, bool isPercentage = false}) {
    final difference = current - previous;
    final isPositive = difference >= 0;
    final percentChange = previous == 0 ? (current > 0 ? 100.0 : 0.0) : (difference / previous * 100).abs();

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
                Text('Current: ${isMoney ? formatMoney(current) : (isPercentage ? '${current.toStringAsFixed(0)}%' : current.toInt())}', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: isPositive ? Colors.green : Colors.red),
                  Text('${percentChange.toStringAsFixed(0)}%', style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('Previous: ${isMoney ? formatMoney(previous) : (isPercentage ? '${previous.toStringAsFixed(0)}%' : previous.toInt())}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  DateRange _getDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'month':
        return DateRangeUtils.thisMonth(now);
      case 'quarter':
        return DateRangeUtils.thisQuarter(now);
      case 'week':
      default:
        return DateRangeUtils.thisWeek(now);
    }
  }
}
