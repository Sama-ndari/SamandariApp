import 'package:flutter/material.dart';
import 'package:samapp/models/habit.dart';
import 'package:samapp/services/habit_streak_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class HabitStreakScreen extends StatefulWidget {
  final Habit habit;

  const HabitStreakScreen({super.key, required this.habit});

  @override
  State<HabitStreakScreen> createState() => _HabitStreakScreenState();
}

class _HabitStreakScreenState extends State<HabitStreakScreen> {
  @override
  Widget build(BuildContext context) {
    final streakService = HabitStreakService();
    final isWeekly = widget.habit.frequency == HabitFrequency.timesPerWeek;
    final currentStreak = isWeekly ? streakService.getCurrentWeeklyStreak(widget.habit) : streakService.getCurrentStreak(widget.habit);
    final longestStreak = isWeekly ? streakService.getLongestWeeklyStreak(widget.habit) : streakService.getLongestStreak(widget.habit);
    final completionRate7Days = streakService.getCompletionRate(widget.habit, 7);
    final completionRate30Days = streakService.getCompletionRate(widget.habit, 30);
    final heatmapData = streakService.getHeatmapData(widget.habit);
    final badge = streakService.getStreakBadge(currentStreak);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
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
                        '$currentStreak ${isWeekly ? 'Week' : 'Day'} Streak',
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
                    '$longestStreak ${isWeekly ? 'weeks' : 'days'}',
                    Icons.emoji_events,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Days',
                    '${widget.habit.completionDates.length}',
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

            // History View
            const Text(
              'History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.habit.frequency == HabitFrequency.daily)
              _buildDailyHeatmap(heatmapData)
            else
              _buildWeeklyHistoryList(streakService),
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

  Widget _buildDailyHeatmap(Map<DateTime, int> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: HeatMap(
          datasets: data,
          startDate: DateTime.now().subtract(const Duration(days: 365)),
          endDate: DateTime.now(),
          colorMode: ColorMode.color,
          showText: false,
          scrollable: true,
          colorsets: {
            1: Colors.green.shade300,
            3: Colors.green.shade500,
            5: Colors.green.shade700,
            10: Colors.green.shade900,
          },
          onClick: (date) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(DateFormat('MMM dd, yyyy').format(date))));
          },
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

  Widget _buildWeeklyHistoryList(HabitStreakService streakService) {
    final today = DateTime.now();
    final totalWeeksSinceCreation = (today.difference(widget.habit.createdAt).inDays / 7).ceil();
    final startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: List.generate(totalWeeksSinceCreation, (weekIndex) {
            final weekStart = startOfThisWeek.subtract(Duration(days: weekIndex * 7));
            if (weekStart.isBefore(widget.habit.createdAt.subtract(const Duration(days: 7)))) return const SizedBox.shrink();

            String title;
            String trailing;

            if (widget.habit.frequency == HabitFrequency.timesPerWeek) {
              final weeklyCompletions = streakService.groupCompletionsByWeek(widget.habit.completionDates);
              final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
              final completions = weeklyCompletions[weekKey]?.length ?? 0;
              final target = widget.habit.weeklyTarget ?? 1;
              title = 'Week of ${DateFormat.yMMMd().format(weekStart)}';
              trailing = '$completions / $target';
            } else { // Specific Days
              final weekEnd = weekStart.add(const Duration(days: 6));
              final completionsInWeek = widget.habit.completionDates.where((d) => d.isAfter(weekStart) && d.isBefore(weekEnd)).length;
              final targetDaysInWeek = widget.habit.specificWeekdays?.length ?? 0;
              title = 'Week of ${DateFormat.yMMMd().format(weekStart)}';
              trailing = '$completionsInWeek / $targetDaysInWeek';
            }

            return ListTile(
              title: Text(title),
              trailing: Text(trailing, style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }).reversed.toList(),
        ),
      ),
    );
  }
}
