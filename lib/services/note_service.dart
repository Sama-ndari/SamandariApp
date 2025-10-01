import 'package:hive/hive.dart';
import 'package:samapp/models/note.dart';
import 'package:uuid/uuid.dart';

class NoteService {
  final Box<Note> _noteBox = Hive.box<Note>('notes');
  final _uuid = const Uuid();

  // Get all notes
  List<Note> getAllNotes() {
    return _noteBox.values.toList();
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    note.id = _uuid.v4();
    await _noteBox.put(note.id, note);
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    await _noteBox.put(note.id, note);
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    await _noteBox.delete(noteId);
  }
}
