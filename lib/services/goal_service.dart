import 'package:hive/hive.dart';
import 'package:samapp/models/goal.dart';
import 'package:samapp/models/expense.dart';
import 'package:uuid/uuid.dart';

class GoalService {
  final Box<Goal> _goalBox = Hive.box<Goal>('goals');
  final Box<Expense> _expenseBox = Hive.box<Expense>('expenses');
  final _uuid = const Uuid();

  // Get all goals
  List<Goal> getAllGoals() {
    return _goalBox.values.toList();
  }

  // Get active goals (not completed)
  List<Goal> getActiveGoals() {
    return _goalBox.values.where((goal) => !goal.isCompleted).toList();
  }

  // Add a new goal
  Future<void> addGoal(Goal goal) async {
    goal.id = _uuid.v4();
    await _goalBox.put(goal.id, goal);
  }

  // Update an existing goal
  Future<void> updateGoal(Goal goal) async {
    await _goalBox.put(goal.id, goal);
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _goalBox.delete(goalId);
  }

  // Update goal progress based on expenses (for savings goals)
  Future<void> updateSavingsGoalProgress(Goal goal) async {
    if (goal.type != GoalType.savings) return;

    // Calculate total expenses since goal creation
    final totalExpenses = _expenseBox.values
        .where((expense) => expense.date.isAfter(goal.createdAt))
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    // Current amount is target minus expenses
    goal.currentAmount = (goal.targetAmount - totalExpenses).clamp(0, goal.targetAmount);
    await updateGoal(goal);
  }

  // Mark goal as completed
  Future<void> completeGoal(String goalId) async {
    final goal = _goalBox.get(goalId);
    if (goal != null) {
      goal.isCompleted = true;
      await updateGoal(goal);
    }
  }
}
