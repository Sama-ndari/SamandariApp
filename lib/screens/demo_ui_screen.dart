import 'package:flutter/material.dart';
import 'package:samapp/widgets/skeleton_loader.dart';
import 'package:samapp/widgets/empty_state.dart';
import 'package:samapp/widgets/loading_overlay.dart';
import 'package:samapp/widgets/animated_transitions.dart';
import 'package:samapp/widgets/in_app_notification.dart';

/// Demo screen showcasing all the new UI widgets
class DemoUIScreen extends StatefulWidget {
  const DemoUIScreen({super.key});

  @override
  State<DemoUIScreen> createState() => _DemoUIScreenState();
}

class _DemoUIScreenState extends State<DemoUIScreen> {
  bool _isLoading = false;
  bool _showSkeleton = false;
  String _selectedDemo = 'animations';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Widgets Demo'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Processing...',
        child: Column(
          children: [
            // Tab selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _buildTab('Animations', 'animations'),
                  _buildTab('Empty States', 'empty'),
                  _buildTab('Skeletons', 'skeleton'),
                  _buildTab('Loading', 'loading'),
                  _buildTab('Notifications', 'notifications'),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = _selectedDemo == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedDemo = value;
          });
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedDemo) {
      case 'animations':
        return _buildAnimationsDemo();
      case 'empty':
        return _buildEmptyStatesDemo();
      case 'skeleton':
        return _buildSkeletonDemo();
      case 'loading':
        return _buildLoadingDemo();
      case 'notifications':
        return _buildNotificationsDemo();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAnimationsDemo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Animation Examples',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        FadeIn(
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.animation),
              title: const Text('Fade In Animation'),
              subtitle: const Text('Smooth fade in effect'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        SlideInFromBottom(
          delay: const Duration(milliseconds: 200),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Slide In From Bottom'),
              subtitle: const Text('Slides up with fade'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        ScaleIn(
          delay: const Duration(milliseconds: 400),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.zoom_in),
              title: const Text('Scale In Animation'),
              subtitle: const Text('Elastic bounce effect'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        const Text(
          'Staggered List',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        StaggeredList(
          children: List.generate(
            5,
            (index) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('Staggered Item ${index + 1}'),
                subtitle: const Text('Animates one after another'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStatesDemo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Empty State Examples',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: SizedBox(
                  height: 400,
                  child: EmptyStates.noTasks(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Show No Tasks Empty State'),
        ),
        const SizedBox(height: 8),
        
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: SizedBox(
                  height: 400,
                  child: EmptyStates.noExpenses(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Show No Expenses Empty State'),
        ),
        const SizedBox(height: 8),
        
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: SizedBox(
                  height: 400,
                  child: EmptyStates.noSearchResults(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Show No Search Results'),
        ),
        const SizedBox(height: 8),
        
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: SizedBox(
                  height: 400,
                  child: EmptyStates.error(
                    context,
                    message: 'Failed to load data',
                    onRetry: () => Navigator.pop(context),
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
          },
          child: const Text('Show Error State'),
        ),
      ],
    );
  }

  Widget _buildSkeletonDemo() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Skeleton Loaders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Switch(
                value: _showSkeleton,
                onChanged: (value) {
                  setState(() {
                    _showSkeleton = value;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _showSkeleton
              ? const SkeletonList(itemCount: 10)
              : ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Item ${index + 1}'),
                    subtitle: Text('Description for item ${index + 1}'),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingDemo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(message: 'Loading data...'),
          const SizedBox(height: 32),
          
          const PulsingLoader(
            icon: Icons.favorite,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 32),
          
          LoadingButton(
            label: 'Submit',
            isLoading: _isLoading,
            icon: Icons.send,
            onPressed: () {
              setState(() => _isLoading = true);
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() => _isLoading = false);
                  NotificationType.success(
                    context,
                    title: 'Success!',
                    message: 'Operation completed',
                  );
                }
              });
            },
          ),
          const SizedBox(height: 16),
          
          ElevatedButton(
            onPressed: () {
              setState(() => _isLoading = true);
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              });
            },
            child: const Text('Show Loading Overlay'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsDemo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'In-App Notifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        ElevatedButton.icon(
          onPressed: () {
            NotificationType.success(
              context,
              title: 'Success!',
              message: 'Your task has been completed successfully',
            );
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Show Success'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        const SizedBox(height: 8),
        
        ElevatedButton.icon(
          onPressed: () {
            NotificationType.error(
              context,
              title: 'Error!',
              message: 'Something went wrong. Please try again',
            );
          },
          icon: const Icon(Icons.error),
          label: const Text('Show Error'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        const SizedBox(height: 8),
        
        ElevatedButton.icon(
          onPressed: () {
            NotificationType.warning(
              context,
              title: 'Warning!',
              message: 'Please review your input before continuing',
            );
          },
          icon: const Icon(Icons.warning),
          label: const Text('Show Warning'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        const SizedBox(height: 8),
        
        ElevatedButton.icon(
          onPressed: () {
            NotificationType.taskReminder(
              context,
              taskTitle: 'Meeting at 3 PM',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task tapped!')),
                );
              },
            );
          },
          icon: const Icon(Icons.task_alt),
          label: const Text('Show Task Reminder'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
        ),
      ],
    );
  }
}
