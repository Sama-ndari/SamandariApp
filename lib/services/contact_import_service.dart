import 'dart:convert';
import 'package:samapp/models/contact.dart';
import 'package:samapp/services/contact_service.dart';

class ContactImportService {
  final ContactService _contactService = ContactService();

  Future<void> importContactsFromJson(String jsonString) async {
    final List<dynamic> contactsList = jsonDecode(jsonString);
    
    for (var contactData in contactsList) {
      final contact = Contact()
        ..name = contactData['name'] ?? ''
        ..phoneNumber = contactData['contact'] ?? ''
        ..email = ''
        ..createdAt = DateTime.now();
      
      await _contactService.addContact(contact);
    }
  }

  Future<int> importFromRegenerationPrompt() async {
    // Read the contacts from REGENERATION_PROMPT.md
    // This is the JSON data from the file
    const contactsJson = '''
[
  {"name": "Ordi", "contact": "+25762356816"},
  {"name": "Phone", "contact": "+25761257332"},
  {"name": "VisitBurundi", "contact": "+25769474705"},
  {"name": "A1", "contact": "+255699832700"},
  {"name": "AbaOne", "contact": "+25769460410"}
]
''';
    
    await importContactsFromJson(contactsJson);
    
    // Return the number of contacts imported
    final List<dynamic> contactsList = jsonDecode(contactsJson);
    return contactsList.length;
  }
}
