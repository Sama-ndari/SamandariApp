import 'package:flutter_test/flutter_test.dart';
import 'package:samapp/services/pagination_service.dart';

void main() {
  group('PaginationService', () {
    setUp(() {
      // Setup test environment if needed
    });

    group('PaginatedResult', () {
      test('should calculate properties correctly', () {
        // Arrange
        final result = PaginatedResult<String>(
          items: ['item1', 'item2', 'item3'],
          page: 0,
          pageSize: 10,
          totalItems: 25,
          totalPages: 3,
          hasNextPage: true,
          hasPreviousPage: false,
        );

        // Assert
        expect(result.isFirstPage, isTrue);
        expect(result.isLastPage, isFalse);
        expect(result.isEmpty, isFalse);
        expect(result.isNotEmpty, isTrue);
        expect(result.startIndex, equals(1));
        expect(result.endIndex, equals(3));
      });

      test('should handle empty result', () {
        // Arrange
        final result = PaginatedResult<String>(
          items: [],
          page: 0,
          pageSize: 10,
          totalItems: 0,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        );

        // Assert
        expect(result.isEmpty, isTrue);
        expect(result.isNotEmpty, isFalse);
        expect(result.isFirstPage, isTrue);
        expect(result.isLastPage, isFalse); // When totalPages=0, page 0 is not the last page (0 != -1)
      });

      test('should handle last page correctly', () {
        // Arrange
        final result = PaginatedResult<String>(
          items: ['item1', 'item2'],
          page: 2,
          pageSize: 10,
          totalItems: 22,
          totalPages: 3,
          hasNextPage: false,
          hasPreviousPage: true,
        );

        // Assert
        expect(result.isFirstPage, isFalse);
        expect(result.isLastPage, isTrue);
        expect(result.startIndex, equals(21));
        expect(result.endIndex, equals(22));
      });
    });

    group('PaginationException', () {
      test('should create exception with message', () {
        // Arrange
        const message = 'Test error message';
        
        // Act
        final exception = PaginationException(message);
        
        // Assert
        expect(exception.message, equals(message));
        expect(exception.toString(), contains(message));
      });
    });
  });
}
