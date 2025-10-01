import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 8)
enum Mood {
  @HiveField(0)
  happy,
  @HiveField(1)
  sad,
  @HiveField(2)
  neutral,
  @HiveField(3)
  excited,
  @HiveField(4)
  calm,
  @HiveField(5)
  anxious,
  @HiveField(6)
  grateful
}

@HiveType(typeId: 9)
class JournalEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String content;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late Mood mood;

  @HiveField(4)
  late List<String> tags;
}
