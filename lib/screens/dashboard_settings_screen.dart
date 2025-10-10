import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DashboardSettingsScreen extends StatefulWidget {
  const DashboardSettingsScreen({super.key});

  @override
  State<DashboardSettingsScreen> createState() => _DashboardSettingsScreenState();
}

class _DashboardSettingsScreenState extends State<DashboardSettingsScreen> {
  late Box<String> _namesBox;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namesBox = Hive.box<String>('dashboard_names');
  }

  void _addName() {
    final name = _textController.text.trim();
    if (name.isNotEmpty && !_namesBox.values.contains(name)) {
      _namesBox.add(name);
      _textController.clear();
    }
  }

  void _deleteName(int index) {
    _namesBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Dashboard Names'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Add a new name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 30),
                  onPressed: _addName,
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _namesBox.listenable(),
              builder: (context, Box<String> box, _) {
                final names = box.values.toList();
                if (names.isEmpty) {
                  return const Center(child: Text('No names added yet.'));
                }
                return ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(names[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteName(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
