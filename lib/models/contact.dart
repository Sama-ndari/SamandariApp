import 'package:azlistview/azlistview.dart';
import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 15)
class Contact extends HiveObject with ISuspensionBean {
  Contact();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phoneNumber;

  @HiveField(3)
  late String email;

  @HiveField(4)
  late DateTime createdAt;

  String? tag;

  // Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON for import
  @override
  String getSuspensionTag() => tag!;

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact()
      ..id = json['id']
      ..name = json['name']
      ..phoneNumber = json['phoneNumber']
      ..email = json['email']
      ..createdAt = DateTime.parse(json['createdAt']);
  }
}
