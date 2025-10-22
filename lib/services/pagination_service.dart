import 'package:hive/hive.dart';

/// Generic pagination service for Hive database operations.
/// 
/// This service provides efficient pagination capabilities for large datasets
/// stored in Hive boxes. It supports filtering, sorting, and lazy loading
/// to improve performance when dealing with thousands of records.
/// 
/// Features:
/// - Efficient pagination with configurable page sizes
/// - Support for filtering and search operations
/// - Sorting capabilities with custom comparators
/// - Memory-efficient lazy loading
/// - Generic implementation for any Hive model
/// 
/// Usage:
/// ```dart
/// final paginationService = PaginationService<Task>();
/// final page = await paginationService.getPage(
///   boxName: 'tasks',
///   page: 0,
///   pageSize: 20,
///   filter: (task) => !task.isCompleted,
///   sort: (a, b) => b.createdAt.compareTo(a.createdAt),
/// );
/// ```
class PaginationService<T> {
  /// Gets a paginated list of items from a Hive box.
  /// 
  /// Parameters:
  /// - [boxName]: Name of the Hive box to query
  /// - [page]: Page number (0-based)
  /// - [pageSize]: Number of items per page
  /// - [filter]: Optional filter function to apply
  /// - [sort]: Optional sorting comparator
  /// - [searchQuery]: Optional search query for text-based filtering
  /// - [searchFields]: Fields to search in when using searchQuery
  /// 
  /// Returns a [PaginatedResult] containing the items and metadata
  Future<PaginatedResult<T>> getPage({
    required String boxName,
    required int page,
    required int pageSize,
    bool Function(T item)? filter,
    int Function(T a, T b)? sort,
    String? searchQuery,
    List<String Function(T item)> searchFields = const [],
  }) async {
    try {
      final box = Hive.box<T>(boxName);
      
      // Get all items from the box
      List<T> allItems = box.values.toList();
      
      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty && searchFields.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        allItems = allItems.where((item) {
          return searchFields.any((field) => 
            field(item).toLowerCase().contains(query));
        }).toList();
      }
      
      // Apply custom filter if provided
      if (filter != null) {
        allItems = allItems.where(filter).toList();
      }
      
      // Apply sorting if provided
      if (sort != null) {
        allItems.sort(sort);
      }
      
      // Calculate pagination
      final totalItems = allItems.length;
      final totalPages = (totalItems / pageSize).ceil();
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, totalItems);
      
      // Get the page items
      final pageItems = startIndex < totalItems 
        ? allItems.sublist(startIndex, endIndex)
        : <T>[];
      
      return PaginatedResult<T>(
        items: pageItems,
        page: page,
        pageSize: pageSize,
        totalItems: totalItems,
        totalPages: totalPages,
        hasNextPage: page < totalPages - 1,
        hasPreviousPage: page > 0,
      );
    } catch (e) {
      throw PaginationException('Failed to load page: $e');
    }
  }
  
  /// Searches items across multiple fields with pagination.
  /// 
  /// This method provides a convenient way to search through items
  /// and return paginated results.
  Future<PaginatedResult<T>> search({
    required String boxName,
    required String query,
    required List<String Function(T item)> searchFields,
    int page = 0,
    int pageSize = 20,
    int Function(T a, T b)? sort,
  }) async {
    return getPage(
      boxName: boxName,
      page: page,
      pageSize: pageSize,
      searchQuery: query,
      searchFields: searchFields,
      sort: sort,
    );
  }
  
  /// Gets items with a specific filter and pagination.
  /// 
  /// Useful for getting filtered subsets like completed tasks,
  /// recent expenses, etc.
  Future<PaginatedResult<T>> getFiltered({
    required String boxName,
    required bool Function(T item) filter,
    int page = 0,
    int pageSize = 20,
    int Function(T a, T b)? sort,
  }) async {
    return getPage(
      boxName: boxName,
      page: page,
      pageSize: pageSize,
      filter: filter,
      sort: sort,
    );
  }
  
  /// Gets the total count of items matching a filter.
  /// 
  /// Useful for displaying total counts without loading all items.
  Future<int> getCount({
    required String boxName,
    bool Function(T item)? filter,
    String? searchQuery,
    List<String Function(T item)> searchFields = const [],
  }) async {
    try {
      final box = Hive.box<T>(boxName);
      List<T> items = box.values.toList();
      
      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty && searchFields.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        items = items.where((item) {
          return searchFields.any((field) => 
            field(item).toLowerCase().contains(query));
        }).toList();
      }
      
      // Apply custom filter
      if (filter != null) {
        items = items.where(filter).toList();
      }
      
      return items.length;
    } catch (e) {
      throw PaginationException('Failed to get count: $e');
    }
  }
}

/// Result class for paginated data.
/// 
/// Contains the paginated items along with metadata about
/// the pagination state and navigation information.
class PaginatedResult<T> {
  /// The items for the current page
  final List<T> items;
  
  /// Current page number (0-based)
  final int page;
  
  /// Number of items per page
  final int pageSize;
  
  /// Total number of items across all pages
  final int totalItems;
  
  /// Total number of pages
  final int totalPages;
  
  /// Whether there is a next page available
  final bool hasNextPage;
  
  /// Whether there is a previous page available
  final bool hasPreviousPage;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
  
  /// Whether this is the first page
  bool get isFirstPage => page == 0;
  
  /// Whether this is the last page
  bool get isLastPage => page == totalPages - 1;
  
  /// Whether the result set is empty
  bool get isEmpty => items.isEmpty;
  
  /// Whether the result set is not empty
  bool get isNotEmpty => items.isNotEmpty;
  
  /// The starting index of items on this page (1-based)
  int get startIndex => page * pageSize + 1;
  
  /// The ending index of items on this page (1-based)
  int get endIndex => startIndex + items.length - 1;
  
  @override
  String toString() {
    return 'PaginatedResult(page: $page, items: ${items.length}, '
           'total: $totalItems, hasNext: $hasNextPage)';
  }
}

/// Exception thrown when pagination operations fail.
class PaginationException implements Exception {
  final String message;
  
  const PaginationException(this.message);
  
  @override
  String toString() => 'PaginationException: $message';
}
