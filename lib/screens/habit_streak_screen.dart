import 'package:flutter/material.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/services/habit_streak_service.dart';
import 'package:intl/intl.dart';

class HabitStreakScreen extends StatelessWidget {
  final Habit habit;

  const HabitStreakScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final streakService = HabitStreakService();
    final currentStreak = streakService.getCurrentStreak(habit);
    final longestStreak = streakService.getLongestStreak(habit);
    final completionRate7Days = streakService.getCompletionRate(habit, 7);
    final completionRate30Days = streakService.getCompletionRate(habit, 30);
    final heatmapData = streakService.getHeatmapData(habit);
    final badge = streakService.getStreakBadge(currentStreak);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Badge
            Center(
              child: Card(
                color: Colors.purple.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        badge,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currentStreak Day Streak',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Longest Streak',
                    '$longestStreak days',
                    Icons.emoji_events,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Days',
                    '${habit.completionDates.length}',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '7 Day Rate',
                    '${completionRate7Days.toStringAsFixed(0)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '30 Day Rate',
                    '${completionRate30Days.toStringAsFixed(0)}%',
                    Icons.show_chart,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Heatmap
            const Text(
              'Last 90 Days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHeatmap(heatmapData),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeatmapLegend('Completed', Colors.green),
                const SizedBox(width: 16),
                _buildHeatmapLegend('Missed', Colors.grey.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(Map<DateTime, int> data) {
    final sortedDates = data.keys.toList()..sort();
    
    // Group by weeks
    final weeks = <List<DateTime>>[];
    List<DateTime> currentWeek = [];
    
    for (var date in sortedDates.reversed) {
      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
      currentWeek.add(date);
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: weeks.map((week) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: week.map((date) {
                  final isCompleted = data[date] == 1;
                  final isToday = DateTime.now().year == date.year &&
                      DateTime.now().month == date.month &&
                      DateTime.now().day == date.day;

                  return Tooltip(
                    message: DateFormat('MMM dd').format(date),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                        border: isToday
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHeatmapLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
