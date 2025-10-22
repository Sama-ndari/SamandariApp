import 'package:flutter_test/flutter_test.dart';
import 'package:samapp/models/legacy_capsule.dart';

void main() {
  group('LegacyCapsule Model', () {
    test('should create capsule with required fields', () {
      // Arrange
      final creationDate = DateTime.now();
      final openDate = DateTime.now().add(const Duration(days: 1));
      const content = 'Test message';
      
      // Act
      final capsule = LegacyCapsule(
        content: content,
        creationDate: creationDate,
        openDate: openDate,
      );
      
      // Assert
      expect(capsule.content, equals(content));
      expect(capsule.creationDate, equals(creationDate));
      expect(capsule.openDate, equals(openDate));
      expect(capsule.id, isNotEmpty);
      expect(capsule.isRead, isFalse);
      expect(capsule.isSent, isFalse);
      expect(capsule.isOpened, isFalse);
    });

    test('should create capsule with recipient information', () {
      // Arrange
      const recipientName = 'John Doe';
      const recipientEmail = 'john@example.com';
      
      // Act
      final capsule = LegacyCapsule(
        content: 'Test message',
        creationDate: DateTime.now(),
        openDate: DateTime.now().add(const Duration(days: 1)),
        recipientName: recipientName,
        recipientEmail: recipientEmail,
      );
      
      // Assert
      expect(capsule.recipientName, equals(recipientName));
      expect(capsule.recipientEmail, equals(recipientEmail));
    });

    test('should generate unique IDs for different capsules', () {
      // Act
      final capsule1 = LegacyCapsule(
        content: 'Message 1',
        creationDate: DateTime.now(),
        openDate: DateTime.now().add(const Duration(days: 1)),
      );
      
      final capsule2 = LegacyCapsule(
        content: 'Message 2',
        creationDate: DateTime.now(),
        openDate: DateTime.now().add(const Duration(days: 1)),
      );
      
      // Assert
      expect(capsule1.id, isNot(equals(capsule2.id)));
    });

    test('should have default values for optional fields', () {
      // Act
      final capsule = LegacyCapsule(
        content: 'Test message',
        creationDate: DateTime.now(),
        openDate: DateTime.now().add(const Duration(days: 1)),
      );
      
      // Assert
      expect(capsule.recipientName, isNull);
      expect(capsule.recipientEmail, isNull);
      expect(capsule.isRead, isFalse);
      expect(capsule.isSent, isFalse);
    });
  });
}
