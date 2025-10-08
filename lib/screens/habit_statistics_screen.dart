import 'package:flutter/material.dart';
import 'package:samapp/models/habit.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:samapp/services/habit_streak_service.dart';
import 'package:intl/intl.dart';
import 'package:samapp/services/habit_streak_service.dart';
import 'package:intl/intl.dart';

class HabitStatisticsScreen extends StatelessWidget {
  final Habit habit;

  const HabitStatisticsScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final streakService = HabitStreakService();
    final isWeekly = habit.frequency == HabitFrequency.timesPerWeek;
    final isSpecificDays = habit.frequency == HabitFrequency.specificDays;

    double totalRate;
    double monthlyRate;
    String totalRateLabel = 'Total Rate';
    String monthlyRateLabel = 'This Month';

    if (isWeekly) {
      final weeklyCompletions = streakService.groupCompletionsByWeek(habit.completionDates);
      final target = habit.weeklyTarget ?? 1;
      double totalPercentage = 0;
      int totalWeeks = 0;

      DateTime now = DateTime.now();
      DateTime loopDate = habit.createdAt;
      while (loopDate.isBefore(now)) {
        totalWeeks++;
        // Find the Monday of the week for the current loop date to use as the key
        final startOfWeek = loopDate.subtract(Duration(days: loopDate.weekday - 1));
        final weekKey = DateFormat('yyyy-MM-dd').format(startOfWeek);
        
        final completions = weeklyCompletions[weekKey]?.length ?? 0;
        totalPercentage += (completions / target).clamp(0, 1);
        loopDate = loopDate.add(const Duration(days: 7));
      }
      totalRate = totalWeeks > 0 ? (totalPercentage / totalWeeks * 100) : 0.0;
      totalRateLabel = 'Weekly Success';

      double last4WeeksPercentage = 0;
      for (int i = 0; i < 4; i++) {
        final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
        final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
        final completions = weeklyCompletions[weekKey]?.length ?? 0;
        last4WeeksPercentage += (completions / target).clamp(0, 1);
      }
      monthlyRate = (last4WeeksPercentage / 4 * 100);
      monthlyRateLabel = 'Last 4 Weeks';

    } else if (isSpecificDays) {
      final targetDaysCount = habit.specificWeekdays?.length ?? 0;
      final totalTargetDays = _calculateTotalTargetDays(habit.createdAt, habit.specificWeekdays ?? []);
      totalRate = totalTargetDays > 0 ? (habit.completionDates.length / totalTargetDays * 100) : 0.0;
      totalRateLabel = 'Overall Adherence';

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final targetDaysThisMonth = _calculateTotalTargetDays(firstDayOfMonth, habit.specificWeekdays ?? [], now);
      final completionsThisMonth = habit.completionDates.where((d) => d.month == now.month && d.year == now.year).length;
      monthlyRate = targetDaysThisMonth > 0 ? (completionsThisMonth / targetDaysThisMonth * 100) : 0.0;
      monthlyRateLabel = 'Monthly Adherence';

    } else {
      final totalDays = DateTime.now().difference(habit.createdAt).inDays + 1;
      totalRate = totalDays > 0 ? (habit.completionDates.length / totalDays * 100) : 0.0;

      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final completionsThisMonth = habit.completionDates.where((d) => d.month == now.month && d.year == now.year).length;
      monthlyRate = (completionsThisMonth / daysInMonth * 100);
    }

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
          if (isWeekly)
            _buildWeeklyHeatmap(context, streakService)
          else if (isSpecificDays)
            _buildSpecificDaysHistory(context)
          else
            _buildHeatMap(context, datasets),
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

  Widget _buildWeeklyHeatmap(BuildContext context, HabitStreakService streakService) {
    final weeklyCompletions = streakService.groupCompletionsByWeek(habit.completionDates);
    final today = DateTime.now();
    final startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final totalWeeksSinceCreation = (today.difference(habit.createdAt).inDays / 7).ceil();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Weekly Goal History", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...List.generate(totalWeeksSinceCreation, (weekIndex) { 
              final weekStart = startOfThisWeek.subtract(Duration(days: weekIndex * 7));
              if (weekStart.isBefore(habit.createdAt.subtract(const Duration(days: 7)))) return const SizedBox.shrink();

              final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
              final completions = weeklyCompletions[weekKey]?.length ?? 0;
              final target = habit.weeklyTarget ?? 1;
              final isSuccess = completions >= target;

              return ListTile(
                leading: Icon(isSuccess ? Icons.check_circle : Icons.cancel, color: isSuccess ? Colors.green : Colors.red),
                title: Text('Week of ${DateFormat.yMMMd().format(weekStart)}'),
                trailing: Text('$completions / $target', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }).reversed.toList(),
          ],
        ),
      ),
    );
  }

  int _calculateTotalTargetDays(DateTime from, List<int> targetWeekdays, [DateTime? to]) {
    to ??= DateTime.now();
    int totalDays = 0;
    
    DateTime currentDate = from;
    while (currentDate.isBefore(to.add(const Duration(days: 1)))) {
        if (targetWeekdays.contains(currentDate.weekday)) {
            totalDays++;
        }
        currentDate = currentDate.add(const Duration(days: 1));
    }
    return totalDays;
  }

  Widget _buildSpecificDaysHistory(BuildContext context) {
    final today = DateTime.now();
    final totalWeeksSinceCreation = (today.difference(habit.createdAt).inDays / 7).ceil();
    final startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Weekly Adherence History", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...List.generate(totalWeeksSinceCreation, (weekIndex) {
              final weekStart = startOfThisWeek.subtract(Duration(days: weekIndex * 7));
              if (weekStart.isBefore(habit.createdAt.subtract(const Duration(days: 7)))) return const SizedBox.shrink();

              final weekEnd = weekStart.add(const Duration(days: 6));
              final completionsInWeek = habit.completionDates.where((d) => d.isAfter(weekStart) && d.isBefore(weekEnd)).length;
              final targetDaysInWeek = habit.specificWeekdays?.length ?? 0;

              return ListTile(
                leading: Icon(completionsInWeek >= targetDaysInWeek ? Icons.check_circle : Icons.cancel, color: completionsInWeek >= targetDaysInWeek ? Colors.green : Colors.red),
                title: Text('Week of ${DateFormat.yMMMd().format(weekStart)}'),
                trailing: Text('$completionsInWeek / $targetDaysInWeek', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }).reversed.toList(),
          ],
        ),
      ),
    );
  }
}
