import 'package:flutter/material.dart';
import 'package:samapp/models/habit.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class HabitStatisticsScreen extends StatelessWidget {
  final Habit habit;

  const HabitStatisticsScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final totalDays = DateTime.now().difference(habit.createdAt).inDays + 1;
    final totalCompletions = habit.completionDates.length;
    final totalCompletionRate = totalDays > 0 ? (totalCompletions / totalDays * 100) : 0.0;

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final completionsThisMonth = habit.completionDates.where((d) => d.month == now.month && d.year == now.year).length;
    final monthlyCompletionRate = (completionsThisMonth / daysInMonth * 100);

    final datasets = {
      for (var date in habit.completionDates)
        DateTime(date.year, date.month, date.day): 1,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('${habit.name} Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStatsRow(context, totalCompletionRate, monthlyCompletionRate),
          const SizedBox(height: 24),
          _buildHeatMap(context, datasets),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, double totalRate, double monthlyRate) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total Rate', '${totalRate.toStringAsFixed(1)}%', Icons.show_chart, Colors.orange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('This Month', '${monthlyRate.toStringAsFixed(1)}%', Icons.calendar_today, Colors.teal),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatMap(BuildContext context, Map<DateTime, int> datasets) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: HeatMap(
          datasets: datasets,
          colorMode: ColorMode.color,
          showText: false,
          scrollable: true,
          colorsets: {
            1: Color(habit.color),
          },
          defaultColor: Colors.grey[200],
          textColor: Colors.white,
          size: 20,
          margin: const EdgeInsets.all(2),
          borderRadius: 4,
        ),
      ),
    );
  }
}
