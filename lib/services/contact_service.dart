import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:samapp/models/contact.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class ContactService {
  final Box<Contact> _contactBox = Hive.box<Contact>('contacts');
  final _uuid = const Uuid();

  // Get all contacts
  List<Contact> getAllContacts() {
    return _contactBox.values.toList();
  }

  // Add a new contact
  Future<void> addContact(Contact contact) async {
    contact.id = _uuid.v4();
    await _contactBox.put(contact.id, contact);
  }

  // Update an existing contact
  Future<void> updateContact(Contact contact) async {
    await _contactBox.put(contact.id, contact);
  }

  // Delete a contact
  Future<void> deleteContact(String contactId) async {
    await _contactBox.delete(contactId);
  }

  // Delete all contacts
  Future<void> deleteAllContacts() async {
    await _contactBox.clear();
  }

  // Export contacts to JSON file
  Future<String> exportContactsToJson() async {
    final contacts = getAllContacts();
    final jsonList = contacts.map((contact) => contact.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    // Get the downloads directory
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/contacts_export.json');
    
    await file.writeAsString(jsonString);
    return file.path;
  }

  // Import contacts from JSON string
  Future<void> importContactsFromJson(String jsonString) async {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    for (var json in jsonList) {
      final contact = Contact.fromJson(json);
      await addContact(contact);
    }
  }

  // Import contacts from simple format (name and contact only)
  Future<int> importContactsFromSimpleJson(String jsonString) async {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    int count = 0;
    
    for (var json in jsonList) {
      final contact = Contact()
        ..name = json['name'] ?? ''
        ..phoneNumber = json['contact'] ?? ''
        ..email = ''
        ..createdAt = DateTime.now();
      await addContact(contact);
      count++;
    }
    
    return count;
  }
}
