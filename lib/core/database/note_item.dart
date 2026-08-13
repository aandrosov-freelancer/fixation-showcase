import 'package:app/core/database/app_database.dart';
import 'package:drift/drift.dart';

class NoteItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get summary => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDate)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDate)();
}

extension NoteQueries on AppDatabase {
  static OrderingTerm byUpdatedAtDesc($NoteItemsTable note) =>
      .desc(note.updatedAt);

  Future<List<NoteItem>> get allNoteItems {
    return (select(noteItems)..orderBy([byUpdatedAtDesc])).get();
  }

  Future<NoteItem?> findNoteById(int id) {
    var note = (select(noteItems)..where(((note) => note.id.equals(id))));
    return note.getSingleOrNull();
  }

  Future<List<NoteItem>> findNotesByFullTextSearch(String query) {
    query = query.trim().toLowerCase();

    Expression<bool> matcher($NoteItemsTable note) =>
        .or([note.title.like('%$query%'), note.content.like('%$query%')]);

    return (select(noteItems)
          ..where(matcher)
          ..orderBy([byUpdatedAtDesc]))
        .get();
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
