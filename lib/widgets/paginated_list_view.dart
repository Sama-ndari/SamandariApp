import 'package:flutter/material.dart';
import 'package:samapp/widgets/skeleton_loader.dart';
import 'package:samapp/widgets/empty_state.dart';

/// A generic paginated list view widget that supports lazy loading.
/// 
/// This widget provides a reusable solution for displaying large datasets
/// with automatic pagination and lazy loading capabilities. It includes
/// loading states, empty states, and error handling.
/// 
/// Features:
/// - Automatic pagination when scrolling to bottom
/// - Customizable page size and loading thresholds
/// - Built-in loading and empty states
/// - Error handling with retry functionality
/// - Pull-to-refresh support
/// - Accessibility support
/// 
/// Usage:
/// ```dart
/// PaginatedListView<Task>(
///   itemBuilder: (context, task, index) => TaskTile(task: task),
///   loadPage: (page, pageSize) => taskService.loadTasks(page, pageSize),
///   emptyStateConfig: EmptyStateConfig(
///     icon: Icons.task_alt,
///     title: 'No Tasks',
///     message: 'Create your first task!',
///   ),
/// )
/// ```
class PaginatedListView<T> extends StatefulWidget {
  /// Builder function for individual list items
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  
  /// Function to load a page of data
  /// Returns a list of items for the requested page
  final Future<List<T>> Function(int page, int pageSize) loadPage;
  
  /// Number of items to load per page (default: 20)
  final int pageSize;
  
  /// Number of items from bottom to trigger next page load (default: 3)
  final int loadThreshold;
  
  /// Configuration for empty state display
  final EmptyStateConfig? emptyStateConfig;
  
  /// Whether to show pull-to-refresh (default: true)
  final bool enableRefresh;
  
  /// Custom loading widget (optional)
  final Widget? loadingWidget;
  
  /// Custom error widget builder (optional)
  final Widget Function(String error, VoidCallback retry)? errorBuilder;
  
  /// Scroll controller (optional)
  final ScrollController? scrollController;
  
  /// Physics for the scroll view
  final ScrollPhysics? physics;
  
  /// Padding for the list view
  final EdgeInsetsGeometry? padding;

  const PaginatedListView({
    super.key,
    required this.itemBuilder,
    required this.loadPage,
    this.pageSize = 20,
    this.loadThreshold = 3,
    this.emptyStateConfig,
    this.enableRefresh = true,
    this.loadingWidget,
    this.errorBuilder,
    this.scrollController,
    this.physics,
    this.padding,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  final List<T> _items = [];
  
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;
  String? _error;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  /// Handles scroll events to trigger pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 
        (widget.loadThreshold * 100)) { // Approximate item height
      _loadNextPage();
    }
  }

  /// Loads the initial page of data
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isInitialLoad = true;
    });

    try {
      final items = await widget.loadPage(0, widget.pageSize);
      setState(() {
        _items.clear();
        _items.addAll(items);
        _currentPage = 0;
        _hasMoreData = items.length >= widget.pageSize;
        _isLoading = false;
        _isInitialLoad = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isInitialLoad = false;
      });
    }
  }

  /// Loads the next page of data
  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final items = await widget.loadPage(nextPage, widget.pageSize);
      
      setState(() {
        _items.addAll(items);
        _currentPage = nextPage;
        _hasMoreData = items.length >= widget.pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      // Show error snackbar for pagination errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more items: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadNextPage,
            ),
          ),
        );
      }
    }
  }

  /// Handles pull-to-refresh
  Future<void> _onRefresh() async {
    await _loadInitialData();
  }

  /// Retries loading after an error
  void _retry() {
    if (_items.isEmpty) {
      _loadInitialData();
    } else {
      _loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show initial loading state
    if (_isInitialLoad && _isLoading) {
      return widget.loadingWidget ?? 
        const SkeletonList();
    }

    // Show error state for initial load
    if (_error != null && _items.isEmpty) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _retry);
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (_items.isEmpty && !_isLoading) {
      if (widget.emptyStateConfig != null) {
        final config = widget.emptyStateConfig!;
        return EmptyState(
          icon: config.icon,
          title: config.title,
          message: config.message,
          actionLabel: config.actionLabel,
          onAction: config.onAction,
          iconColor: config.iconColor,
        );
      }
      
      return const Center(
        child: Text('No items found'),
      );
    }

    // Build the list
    Widget listView = ListView.builder(
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      itemCount: _items.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index >= _items.length) {
          return Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }

        return widget.itemBuilder(context, _items[index], index);
      },
    );

    // Wrap with pull-to-refresh if enabled
    if (widget.enableRefresh) {
      listView = RefreshIndicator(
        onRefresh: _onRefresh,
        child: listView,
      );
    }

    return listView;
  }
}

/// Configuration class for empty state display
class EmptyStateConfig {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });
}
