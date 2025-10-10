import 'package:flutter/material.dart';
import 'package:samapp/models/habit.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:samapp/services/habit_analytics_service.dart';
import 'package:intl/intl.dart';

class HabitStatisticsScreen extends StatelessWidget {
  final Habit habit;

  const HabitStatisticsScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final analytics = HabitAnalytics(habit);
    final isWeekly = habit.frequency == HabitFrequency.timesPerWeek;
    final isSpecificDays = habit.frequency == HabitFrequency.specificDays;

    // Use the new service for all calculations
    final totalAdherence = analytics.getAdherenceForPeriod(habit.createdAt, DateTime.now());
    final monthlyAdherence = analytics.getAdherenceForPeriod(
      DateTime(DateTime.now().year, DateTime.now().month, 1),
      DateTime.now(),
    );

    final totalRate = totalAdherence * 100;
    final monthlyRate = monthlyAdherence * 100;
    const totalRateLabel = 'Overall Adherence';
    const monthlyRateLabel = 'Monthly Adherence';

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
          _buildStatsRow(context, totalRate, monthlyRate, totalRateLabel, monthlyRateLabel),
          const SizedBox(height: 24),
          _buildHeatMap(context, datasets),
          if (habit.frequency == HabitFrequency.daily)
            _buildCompletionHistory(context),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, double totalRate, double monthlyRate, String totalLabel, String monthlyLabel) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(totalLabel, '${totalRate.toStringAsFixed(1)}%', Icons.show_chart, Colors.orange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(monthlyLabel, '${monthlyRate.toStringAsFixed(1)}%', Icons.calendar_today, Colors.teal),
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

  Widget _buildCompletionHistory(BuildContext context) {
    final sortedDates = habit.completionDates.toList()..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            'Completion History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              return ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text(DateFormat.yMMMMd().format(date)),
                trailing: Text(DateFormat.jm().format(date), style: Theme.of(context).textTheme.bodySmall),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
          ),
        ),
      ],
    );
  }
}
