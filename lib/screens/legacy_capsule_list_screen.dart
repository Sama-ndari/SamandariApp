import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samapp/models/legacy_capsule.dart';
import 'package:samapp/screens/add_edit_legacy_capsule_screen.dart';
import 'package:samapp/screens/view_legacy_capsule_screen.dart';
import 'package:intl/intl.dart';

class LegacyCapsuleListScreen extends StatefulWidget {
  const LegacyCapsuleListScreen({super.key});

  @override
  State<LegacyCapsuleListScreen> createState() => _LegacyCapsuleListScreenState();
}

class _LegacyCapsuleListScreenState extends State<LegacyCapsuleListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legacy Capsules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            tooltip: 'Delete Read Capsules',
            onPressed: () => _showDeleteReadConfirmation(),
          ),
        ],
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
                    style: TextStyle(fontWeight: capsule.isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text(isLocked ? 'A message awaits...' : 'Ready to open!', style: TextStyle(color: capsule.isRead ? Colors.grey : null)),
                  trailing: capsule.isRead ? const Icon(Icons.visibility_off, color: Colors.grey, size: 20) : const Icon(Icons.chevron_right),
                  onTap: () {
                    if (!isLocked) {
                      // Mark as read when opened
                      if (!capsule.isRead) {
                        capsule.isRead = true;
                        capsule.save();
                      }
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

  void _showDeleteReadConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Read Capsules?'),
        content: const Text('This will permanently delete all capsules that you have already opened. Are you sure?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              final box = Hive.box<LegacyCapsule>('legacy_capsules');
              final readCapsules = box.values.where((c) => c.isRead).toList();
              for (var capsule in readCapsules) {
                capsule.delete();
              }
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${readCapsules.length} read capsules deleted.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
