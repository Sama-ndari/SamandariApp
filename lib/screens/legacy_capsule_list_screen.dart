import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:samapp/screens/add_edit_legacy_capsule_screen.dart';
import 'package:samapp/screens/view_legacy_capsule_screen.dart';
import 'package:intl/intl.dart';

class LegacyCapsuleListScreen extends StatelessWidget {
  const LegacyCapsuleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legacy Capsules'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<LegacyCapsule>('legacy_capsules').listenable(),
        builder: (context, Box<LegacyCapsule> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text(
                'No capsules yet. Create one for your future self!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final capsules = box.values.toList();
          // Sort by creation date, newest first
          capsules.sort((a, b) => b.creationDate.compareTo(a.creationDate));

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: capsules.length,
            itemBuilder: (context, index) {
              final capsule = capsules[index];
              final isLocked = DateTime.now().isBefore(capsule.openDate);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: ListTile(
                  leading: Icon(
                    isLocked ? Icons.lock_clock : Icons.lock_open,
                    color: isLocked ? Colors.amber.shade700 : Colors.green,
                  ),
                  title: Text(
                    isLocked 
                      ? 'Locked until ${DateFormat.yMMMd().format(capsule.openDate)}'
                      : 'Capsule from ${DateFormat.yMMMd().format(capsule.creationDate)}',
                  ),
                  subtitle: Text(isLocked ? 'A message awaits...' : 'Ready to open!'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (!isLocked) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ViewLegacyCapsuleScreen(capsule: capsule),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditLegacyCapsuleScreen(),
            ),
          );
        },
        tooltip: 'Create Capsule',
        child: const Icon(Icons.add),
      ),
    );
  }
}
