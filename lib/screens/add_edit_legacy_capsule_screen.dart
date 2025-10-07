import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:samapp/screens/share_legacy_capsule_screen.dart';

class AddEditLegacyCapsuleScreen extends StatefulWidget {
  const AddEditLegacyCapsuleScreen({super.key});

  @override
  State<AddEditLegacyCapsuleScreen> createState() => _AddEditLegacyCapsuleScreenState();
}

class _AddEditLegacyCapsuleScreenState extends State<AddEditLegacyCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _recipientController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 365)); // Default to one year from now

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveCapsule() {
    if (_formKey.currentState!.validate()) {
      final recipientName = _recipientController.text.trim();

      final newCapsule = LegacyCapsule(
        content: _contentController.text,
        creationDate: DateTime.now(),
        openDate: _selectedDate,
        recipientName: recipientName.isNotEmpty ? recipientName : null,
      );

      final box = Hive.box<LegacyCapsule>('legacy_capsules');
      box.add(newCapsule);

      if (newCapsule.recipientName != null) {
        Navigator.of(context).pop(); // Pop the add/edit screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ShareLegacyCapsuleScreen(capsule: newCapsule),
          ),
        );
      } else {
        Navigator.of(context).pop(); // Just pop for personal capsules
      }
    }
  }

  Future<void> _autoGenerateMessage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse('https://creative-muse-backend.vercel.app/api/get-muse'); // Re-using the same backend
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': 'Write a short, kind, and encouraging message to a future self. Start with \"Dear Future Me,\"'}),
      ).timeout(const Duration(seconds: 20));

      Navigator.of(context).pop(); // Close loading dialog

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _contentController.text = data['muse'];
        });
      } else {
        throw Exception('Failed to generate message. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Show error dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Capsule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCapsule,
            tooltip: 'Save Capsule',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Your message to the future',
                  hintText: 'What do you want to remember? What words of encouragement do you have?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Open Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _recipientController,
                decoration: const InputDecoration(
                  labelText: 'Recipient\'s Name (Optional)',
                  hintText: 'Leave blank to make this a capsule for yourself',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _autoGenerateMessage,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Auto-generate with AI'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
