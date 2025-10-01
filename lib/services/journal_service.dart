import 'package:hive/hive.dart';
import 'package:samapp/models/journal_entry.dart';
import 'package:uuid/uuid.dart';

class JournalService {
  final Box<JournalEntry> _journalBox = Hive.box<JournalEntry>('journal_entries');
  final _uuid = const Uuid();

  // Get all journal entries
  List<JournalEntry> getAllJournalEntries() {
    return _journalBox.values.toList();
  }

  // Add a new journal entry
  Future<void> addJournalEntry(JournalEntry entry) async {
    entry.id = _uuid.v4();
    await _journalBox.put(entry.id, entry);
  }

  // Update an existing journal entry
  Future<void> updateJournalEntry(JournalEntry entry) async {
    await _journalBox.put(entry.id, entry);
  }

  // Delete a journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    await _journalBox.delete(entryId);
  }
}
