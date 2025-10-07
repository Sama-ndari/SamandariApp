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

  LegacyCapsule({
    required this.content,
    required this.creationDate,
    required this.openDate,
    this.recipientName,
  }) {
    id = const Uuid().v4();
    isOpened = false;
  }
}
