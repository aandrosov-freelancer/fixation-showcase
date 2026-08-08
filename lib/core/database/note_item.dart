import 'package:app/core/database/app_database.dart';
import 'package:drift/drift.dart';

class NoteItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDate)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDate)();
}

extension NoteQueries on AppDatabase {
  Future<List<NoteItem>> get allNoteItems => select(noteItems).get();

  Future<NoteItem?> getNoteById(int id) {
    var note = (select(noteItems)..where(((note) => note.id.equals(id))));
    return note.getSingleOrNull();
  }

  Future<int> insertNote(NoteItemsCompanion note) {
    return into(noteItems).insert(note);
  }

  Future<bool> updateNote(NoteItem note) {
    return update(noteItems).replace(note);
  }

  Future<int> deleteNote({required int id}) {
    return (delete(noteItems)..where((note) => note.id.equals(id))).go();
  }
}
