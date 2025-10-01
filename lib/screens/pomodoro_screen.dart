import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:samapp/models/pomodoro_session.dart';
import 'package:uuid/uuid.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final Box<PomodoroSession> _sessionBox = Hive.box<PomodoroSession>('pomodoro_sessions');
  final Uuid _uuid = const Uuid();

  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes default
  bool _isRunning = false;
  bool _isBreak = false;
  int _workDuration = 25; // minutes
  int _shortBreak = 5; // minutes
  int _longBreak = 15; // minutes
  int _sessionsCompleted = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isBreak
          ? (_sessionsCompleted % 4 == 0 ? _longBreak : _shortBreak) * 60
          : _workDuration * 60;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    
    if (!_isBreak) {
      // Work session completed
      _sessionsCompleted++;
      _saveSession();
      
      // Start break
      setState(() {
        _isBreak = true;
        _isRunning = false;
        _remainingSeconds = (_sessionsCompleted % 4 == 0 ? _longBreak : _shortBreak) * 60;
      });
      
      _showCompletionDialog('Work Session Complete!', 
          'Great job! Time for a ${_sessionsCompleted % 4 == 0 ? 'long' : 'short'} break.');
    } else {
      // Break completed
      setState(() {
        _isBreak = false;
        _isRunning = false;
        _remainingSeconds = _workDuration * 60;
      });
      
      _showCompletionDialog('Break Complete!', 'Ready to start another session?');
    }
  }

  void _saveSession() {
    final session = PomodoroSession()
      ..id = _uuid.v4()
      ..startTime = DateTime.now().subtract(Duration(minutes: _workDuration))
      ..endTime = DateTime.now()
      ..durationMinutes = _workDuration
      ..completed = true
      ..taskId = null
      ..notes = null;
    
    _sessionBox.put(session.id, session);
  }

  void _showCompletionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showHistory() {
    final sessions = _sessionBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: sessions.isEmpty
              ? const Center(child: Text('No sessions yet'))
              : ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final duration = session.durationMinutes;
                    final dateStr = '${session.startTime.day}/${session.startTime.month} ${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}';
                    return ListTile(
                      leading: Icon(
                        session.completed ? Icons.check_circle : Icons.cancel,
                        color: session.completed ? Colors.green : Colors.orange,
                      ),
                      title: Text('$duration min Focus'),
                      subtitle: Text(dateStr),
                      trailing: session.completed
                          ? const Icon(Icons.done, color: Colors.green)
                          : const Text('Incomplete', style: TextStyle(color: Colors.orange)),
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = (_isBreak 
        ? (_sessionsCompleted % 4 == 0 ? _longBreak : _shortBreak) 
        : _workDuration) * 60;
    final progress = 1 - (_remainingSeconds / totalSeconds);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'View History',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Session indicator
            Text(
              _isBreak ? 'Break Time' : 'Focus Time',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isBreak ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Session ${_sessionsCompleted + 1}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),

            // Circular progress
            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isBreak ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_remainingSeconds / 60).ceil()} min left',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : 'Start'),
                  backgroundColor: _isBreak ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: _resetTimer,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Stats
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Sessions', _sessionsCompleted.toString(), Icons.check_circle),
                    _buildStatItem('Total', '${_sessionsCompleted * _workDuration} min', Icons.timer),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Work Duration'),
              trailing: Text('$_workDuration min'),
              onTap: () => _showDurationPicker('Work', _workDuration, (value) {
                setState(() => _workDuration = value);
                if (!_isBreak && !_isRunning) {
                  _remainingSeconds = _workDuration * 60;
                }
              }),
            ),
            ListTile(
              title: const Text('Short Break'),
              trailing: Text('$_shortBreak min'),
              onTap: () => _showDurationPicker('Short Break', _shortBreak, (value) {
                setState(() => _shortBreak = value);
              }),
            ),
            ListTile(
              title: const Text('Long Break'),
              trailing: Text('$_longBreak min'),
              onTap: () => _showDurationPicker('Long Break', _longBreak, (value) {
                setState(() => _longBreak = value);
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker(String title, int currentValue, Function(int) onChanged) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(12, (index) {
            final value = (index + 1) * 5;
            return RadioListTile<int>(
              title: Text('$value minutes'),
              value: value,
              groupValue: currentValue,
              onChanged: (val) {
                if (val != null) {
                  onChanged(val);
                  Navigator.of(context).pop();
                }
              },
            );
          }),
        ),
      ),
    );
  }
}
