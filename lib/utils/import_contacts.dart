import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:samapp/models/contact.dart';
import 'package:uuid/uuid.dart';

class ContactImporter {
  static Future<int> importFromJson(String jsonString) async {
    final Box<Contact> contactBox = Hive.box<Contact>('contacts');
    final Uuid uuid = const Uuid();
    
    try {
      final List<dynamic> contactsJson = json.decode(jsonString);
      int imported = 0;
      
      for (var item in contactsJson) {
        final name = item['name'] as String;
        final phone = item['contact'] as String;
        
        // Check if contact already exists
        bool exists = contactBox.values.any((c) => 
          c.name == name && c.phoneNumber == phone
        );
        
        if (!exists) {
          final contact = Contact()
            ..id = uuid.v4()
            ..name = name
            ..phoneNumber = phone
            ..email = ''
            ..createdAt = DateTime.now();
          
          await contactBox.put(contact.id, contact);
          imported++;
        }
      }
      
      return imported;
    } catch (e) {
      print('Error importing contacts: $e');
      return 0;
    }
  }
}
