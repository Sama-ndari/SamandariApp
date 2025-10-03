import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/water_intake.dart';
import 'package:samapp/services/water_intake_service.dart';
import 'package:samapp/services/haptic_service.dart';
import 'package:samapp/widgets/in_app_notification.dart';
import 'package:samapp/widgets/water_glass_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  final WaterIntakeService _waterIntakeService = WaterIntakeService();
  double _dailyGoal = 2000; // 2000 ml
  late ConfettiController _confettiController;
  bool _hasShownCelebration = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showSettingsDialog() {
    final controller = TextEditingController(text: _dailyGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily Goal (ml)',
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newGoal = double.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                setState(() {
                  _dailyGoal = newGoal;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Daily goal set to ${newGoal.toInt()} ml')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog() {
    final box = Hive.box<WaterIntake>('water_intake');
    final history = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Water Intake History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: history.isEmpty
              ? const Center(child: Text('No history yet'))
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final intake = history[index];
                    final dateStr = '${intake.date.day}/${intake.date.month}/${intake.date.year}';
                    return ListTile(
                      leading: const Icon(Icons.water_drop, color: Colors.blue),
                      title: Text('${intake.amount.toInt()} ml'),
                      subtitle: Text(dateStr),
                      trailing: Text(
                        '${(intake.amount / _dailyGoal * 100).toInt()}%',
                        style: TextStyle(
                          color: intake.amount >= _dailyGoal ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(int amount) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        HapticService.lightImpact();
        
        // Get current amount before adding
        final box = Hive.box<WaterIntake>('water_intake');
        final today = DateTime.now();
        final todayKey = DateTime(today.year, today.month, today.day).toString();
        final currentIntake = box.get(todayKey);
        final previousAmount = currentIntake?.amount ?? 0;
        
        // Add water
        _waterIntakeService.addWater(amount);
        
        // Check if goal just reached
        final newIntake = box.get(todayKey);
        final newAmount = newIntake?.amount ?? 0;
        
        if (previousAmount < _dailyGoal && newAmount >= _dailyGoal && !_hasShownCelebration) {
          setState(() {
            _hasShownCelebration = true;
          });
          
          // Trigger confetti
          _confettiController.play();
          
          // Show celebration
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              HapticService.success();
              NotificationType.success(
                context,
                title: 'Goal Reached! 🎉',
                message: 'You\'ve reached your daily water goal of ${_dailyGoal.toInt()} ml!',
              );
            }
          });
        }
      },
      child: Text(
        '+$amount ml',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final box = Hive.box<WaterIntake>('water_intake');
    final now = DateTime.now();
    final weekData = <FlSpot>[];
    
    // Find all water intake entries and organize by date
    final intakesByDate = <String, double>{};
    for (var intake in box.values) {
      final key = DateTime(intake.date.year, intake.date.month, intake.date.day).toString();
      intakesByDate[key] = intake.amount.toDouble();
    }

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateTime(date.year, date.month, date.day).toString();
      final amount = (intakesByDate[key] ?? 0) / 1000; // Convert to liters
      weekData.add(FlSpot((6 - i).toDouble(), amount));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}L',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = now.subtract(Duration(days: (6 - value.toInt())));
                          return Text(
                            DateFormat('E').format(date).substring(0, 1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: _dailyGoal / 1000 + 0.5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: weekData,
                      isCurved: true,
                      color: const Color(0xFF06B6D4),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF06B6D4).withOpacity(0.2),
                      ),
                    ),
                  ],
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: _dailyGoal / 1000,
                        color: Colors.green,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (line) => 'Goal',
                          style: const TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showSettingsDialog,
                tooltip: 'Set Daily Goal',
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: IconButton(
                icon: const Icon(Icons.history),
                onPressed: _showHistoryDialog,
                tooltip: 'View History',
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ValueListenableBuilder(
              valueListenable: Hive.box<WaterIntake>('water_intake').listenable(),
              builder: (context, Box<WaterIntake> box, _) {
                final waterIntake = _waterIntakeService.getWaterIntakeForToday();
                final currentAmount = waterIntake?.amount ?? 0;
                final progress = (currentAmount / _dailyGoal).clamp(0.0, 1.0);

                // Reset celebration flag when day changes or progress < 1
                if (progress < 1.0) {
                  _hasShownCelebration = false;
                }

                return Column(
                  children: [
                    // Water Glass Animation
                    WaterGlassWidget(
                      progress: progress,
                      height: 320,
                      width: 200,
                    ),
                    const SizedBox(height: 20),
                    
                    // Current Amount
                    Text(
                      '${currentAmount.toInt()} / ${_dailyGoal.toInt()} ml',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}% of daily goal',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Quick Add Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAddButton(250),
                        _buildAddButton(500),
                        _buildAddButton(750),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Reset Button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Today'),
                      onPressed: () {
                        _waterIntakeService.resetWaterIntake();
                        setState(() {
                          _hasShownCelebration = false;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    
                    // Weekly Chart
                    _buildWeeklyChart(),
                  ],
                );
              },
            ),
          ),
          
          // Confetti Animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // Down
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
              colors: const [
                Colors.blue,
                Colors.cyan,
                Colors.lightBlue,
                Colors.teal,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
