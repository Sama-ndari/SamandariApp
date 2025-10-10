import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/expense.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiChatService {
  late final String _apiUrl = dotenv.env['CREATIVE_MUSE_API_URL']!;

  Future<String> getResponse(String message, bool useContext) async {
    try {
      String finalPrompt = message;
      if (useContext) {
        final contextString = await _gatherContextAsString();
        finalPrompt = '$contextString\n\nUser question: "$message"';
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': finalPrompt}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['muse'] ?? 'Sorry, I could not understand that.';
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Sorry, I am having trouble connecting. Please check your internet connection.';
    }
  }

  Future<String> _gatherContextAsString() async {
    final taskBox = Hive.box<Task>('tasks');
    final expenseBox = Hive.box<Expense>('expenses');

    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    final recentTasks = taskBox.values.where((t) => t.dueDate.isAfter(startOfWeek)).map((t) => '- ${t.title}').toList();
    final recentExpenses = expenseBox.values.where((e) => e.date.isAfter(startOfWeek)).map((e) => '- ${e.description}: ${e.amount}').toList();

    String context = 'Here is some context about me:\n';
    if (recentTasks.isNotEmpty) {
      context += '\nRecent Tasks:\n${recentTasks.join('\n')}\n';
    }
    if (recentExpenses.isNotEmpty) {
      context += '\nRecent Expenses:\n${recentExpenses.join('\n')}\n';
    }

    return context;
  }
}
