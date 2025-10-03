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
  grateful,
  @HiveField(7)
  angry,
  @HiveField(8)
  loved,
  @HiveField(9)
  peaceful,
  @HiveField(10)
  stressed,
  @HiveField(11)
  energetic,
  @HiveField(12)
  tired,
  @HiveField(13)
  hopeful,
  @HiveField(14)
  lonely,
  @HiveField(15)
  confused,
  @HiveField(16)
  proud,
  @HiveField(17)
  disappointed,
  @HiveField(18)
  content,
  @HiveField(19)
  inspired
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
