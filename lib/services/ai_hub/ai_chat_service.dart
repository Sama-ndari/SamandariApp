import 'dart:convert';
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:samapp/models/task.dart';
import 'package:samapp/models/expense.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiChatService {
  late final String _apiUrl = dotenv.env['CREATIVE_MUSE_API_URL']!;

  Future<String> getResponse(String message, bool useContext) async {
    String finalPrompt = message;
    if (useContext) {
      final contextString = await _gatherContextAsString();
      finalPrompt = '$contextString\n\nUser question: "$message"';
    }

    try {
      // print('AI CHAT: Sending request to: $_apiUrl');
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': finalPrompt}),
      ).timeout(const Duration(seconds: 90));

      // print('AI CHAT: Received response with status: ${response.statusCode}');
      // print('AI CHAT: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // The backend sends a JSON object with a 'muse' field.
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['muse'] != null) {
          return data['muse'];
        } else {
          return 'Sorry, I received an unexpected response.';
        }
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } on TimeoutException catch (e) {
      print('AI CHAT ERROR: Request timed out. $e');
      return 'Sorry, the request timed out. The AI is taking too long to respond.';
    } on SocketException catch (e) {
      print('AI CHAT ERROR: Network/Socket error. $e');
      return 'Sorry, I am having trouble connecting. Please check your internet connection or the API URL.';
    } catch (e) {
      print('AI CHAT ERROR: An unexpected error occurred. $e');
      return 'An unexpected error occurred. Please try again.';
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
