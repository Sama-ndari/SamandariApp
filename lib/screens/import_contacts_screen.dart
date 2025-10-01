import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samapp/utils/import_contacts.dart';

class ImportContactsScreen extends StatefulWidget {
  const ImportContactsScreen({super.key});

  @override
  State<ImportContactsScreen> createState() => _ImportContactsScreenState();
}

class _ImportContactsScreenState extends State<ImportContactsScreen> {
  bool _isImporting = false;
  String? _result;

  Future<void> _importContacts() async {
    setState(() {
      _isImporting = true;
      _result = null;
    });

    try {
      // Read the JSON file from assets or from the REGENERATION_PROMPT.md
      final jsonString = await rootBundle.loadString('REGENERATION_PROMPT.md');
      
      // Extract JSON array from the file
      final startIndex = jsonString.indexOf('[');
      final endIndex = jsonString.lastIndexOf(']') + 1;
      
      if (startIndex != -1 && endIndex > startIndex) {
        final contactsJson = jsonString.substring(startIndex, endIndex);
        final imported = await ContactImporter.importFromJson(contactsJson);
        
        setState(() {
          _result = 'Successfully imported $imported contacts!';
          _isImporting = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported $imported contacts'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Could not find contacts JSON in file');
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isImporting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Contacts'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.contacts,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Import Contacts from JSON',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This will import all contacts from REGENERATION_PROMPT.md',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_isImporting)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _importContacts,
                  icon: const Icon(Icons.upload),
                  label: const Text('Import Contacts'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                ),
              const SizedBox(height: 24),
              if (_result != null)
                Card(
                  color: _result!.contains('Error')
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _result!,
                      style: TextStyle(
                        color: _result!.contains('Error')
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
