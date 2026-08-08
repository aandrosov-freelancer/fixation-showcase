import 'package:app/core/database/app_database.dart';
import 'package:app/core/database/note_item.dart';
import 'package:app/features/notes/data/mappers/note_mapper.dart';
import 'package:app/features/notes/data/models/note_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final notesRepositoryProvider = Provider(
  (ref) => NotesRepository(appDatabase: ref.watch(appDatabaseProvider)),
);

class NotesRepository {
  final AppDatabase _appDatabase;

  NotesRepository({required this._appDatabase});

  Future<List<NoteModel>> get allNotes async {
    final notes = await _appDatabase.allNoteItems;
    return notes.map(NoteMapper.toModel).toList();
  }

  Future<NoteModel?> getNoteById({required int id}) async {
    final note = await _appDatabase.findNoteById(id);
    return note != null ? NoteMapper.toModel(note) : null;
  }

  Future<int> addNote(NoteModel note) async {
    final noteCompanion = NoteMapper.toItemCompanion(note);
    return await _appDatabase.insertNote(noteCompanion);
  }

  Future<bool> updateNote(NoteModel note) {
    final noteItem = NoteMapper.toItem(note);
    return _appDatabase.updateNote(noteItem);
  }

  Future<int> deleteNote({required int id}) {
    return _appDatabase.deleteNote(id: id);
  }

  Future<List<NoteModel>> getNotesByFullTextSearch({
    required String query,
  }) async {
    final notes = await _appDatabase.findNotesByFullTextSearch(query);
    return notes.map(NoteMapper.toModel).toList();
  }
}
