import 'package:flutter/material.dart';
import 'package:samapp/services/smart_suggestions_service.dart';
import 'package:samapp/screens/expenses_screen.dart';
import 'package:samapp/screens/tasks_screen.dart';
import 'package:samapp/screens/habits_screen.dart';
import 'package:samapp/screens/goals_screen.dart';
import 'package:samapp/screens/budget_management_screen.dart';

class SuggestionsWidget extends StatelessWidget {
  const SuggestionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestionsService = SmartSuggestionsService();
    final suggestions = suggestionsService.getAllSuggestions();

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show top 3 suggestions
    final topSuggestions = suggestions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Suggestions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...topSuggestions.map((suggestion) => _buildSuggestionCard(context, suggestion)),
      ],
    );
  }

  Widget _buildSuggestionCard(BuildContext context, Suggestion suggestion) {
    Color color;
    switch (suggestion.type) {
      case SuggestionType.budget:
        color = Colors.green;
        break;
      case SuggestionType.task:
        color = Colors.blue;
        break;
      case SuggestionType.habit:
        color = Colors.purple;
        break;
      case SuggestionType.goal:
        color = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            _getIconForType(suggestion.type),
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          suggestion.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          suggestion.description,
          style: const TextStyle(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: suggestion.action != null
            ? Icon(Icons.arrow_forward_ios, size: 16, color: color)
            : null,
        onTap: () {
          _handleSuggestionTap(context, suggestion);
        },
      ),
    );
  }

  void _handleSuggestionTap(BuildContext context, Suggestion suggestion) {
    Widget? screen;
    
    // Navigate to the relevant module based on suggestion type
    switch (suggestion.type) {
      case SuggestionType.budget:
        // Check if it's a "create budget" suggestion
        if (suggestion.action?.contains('Create Budget') ?? false) {
          screen = const BudgetManagementScreen();
        } else {
          screen = const ExpensesScreen();
        }
        break;
      case SuggestionType.task:
        screen = const TasksScreen();
        break;
      case SuggestionType.habit:
        screen = const HabitsScreen();
        break;
      case SuggestionType.goal:
        screen = const GoalsScreen();
        break;
    }
    
    if (screen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  IconData _getIconForType(SuggestionType type) {
    switch (type) {
      case SuggestionType.budget:
        return Icons.account_balance_wallet;
      case SuggestionType.task:
        return Icons.task_alt;
      case SuggestionType.habit:
        return Icons.repeat;
      case SuggestionType.goal:
        return Icons.flag;
    }
  }
}
