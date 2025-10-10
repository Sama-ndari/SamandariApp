import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'legacy_capsule.g.dart';

@HiveType(typeId: 23) // Ensure this typeId is unique
class LegacyCapsule extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String content;

  @HiveField(2)
  late DateTime creationDate;

  @HiveField(3)
  late DateTime openDate;

  @HiveField(4)
  String? recipientName;

  @HiveField(5)
  late bool isOpened;

  @HiveField(6)
  String? recipientEmail;

  @HiveField(7)
  bool isRead;

  @HiveField(8)
  bool isSent;

  LegacyCapsule({
    required this.content,
    required this.creationDate,
    required this.openDate,
    this.recipientName,
    this.recipientEmail,
    this.isRead = false,
    this.isSent = false,
  }) {
    id = const Uuid().v4();
    isOpened = false;
  }
}
