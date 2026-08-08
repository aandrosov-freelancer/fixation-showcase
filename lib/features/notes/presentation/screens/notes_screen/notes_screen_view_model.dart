import 'dart:async';

import 'package:app/features/notes/data/models/note_model.dart';
import 'package:app/features/notes/data/repositories/notes_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final notesScreenViewModelProvider = AsyncNotifierProvider(
  () => NotesScreenViewModel(),
  isAutoDispose: true,
);

final class NotesScreenViewModel extends AsyncNotifier<List<NoteModel>> {
  late final NotesRepository _notesRepository;

  @override
  FutureOr<List<NoteModel>> build() async {
    _notesRepository = ref.watch(notesRepositoryProvider);
    searchNotes();
    return const [];
  }

  Future<void> searchNotes({String? query}) async {
    state = .loading();

    state = await .guard(() async {
      query = query?.trim();
      if (query?.isEmpty ?? true) {
        return await _notesRepository.allNotes;
      }

      return _notesRepository.getNotesByFullTextSearch(query: query!);
    });
  }

  Future<void> deleteNote({required int id}) async {
    final previousValue = state.value;
    state = .loading();

    state = await .guard(() async {
      await _notesRepository.deleteNote(id: id);
      previousValue!.removeWhere((note) => note.id == id);
      return previousValue;
    });
  }
}
