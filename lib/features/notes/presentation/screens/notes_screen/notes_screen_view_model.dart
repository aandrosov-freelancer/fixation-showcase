import 'dart:async';

import 'package:app/core/router/app_router.dart';
import 'package:app/core/router/app_routes.dart';
import 'package:app/core/services/dialog_service.dart';
import 'package:app/features/notes/data/models/note_model.dart';
import 'package:app/features/notes/data/repositories/notes_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final notesScreenViewModelProvider = AsyncNotifierProvider(
  () => NotesScreenViewModel(),
  isAutoDispose: true,
);

final class NotesScreenViewModel extends AsyncNotifier<List<NoteModel>> {
  late final GoRouter _router;
  late final DialogService _dialogService;
  late final NotesRepository _notesRepository;

  @override
  FutureOr<List<NoteModel>> build() async {
    _router = ref.watch(routerProvider);
    _dialogService = ref.watch(dialogServiceProvider);
    _notesRepository = ref.watch(notesRepositoryProvider);

    return await _notesRepository.allNotes;
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
    Future<void> delete() async {
      final previousValue = state.value;

      state = .loading();
      state = await .guard(() async {
        await _notesRepository.deleteNote(id: id);
        previousValue!.removeWhere((note) => note.id == id);
        return previousValue;
      });
    }

    _dialogService.showDeleteNoteDialog(onDelete: delete);
  }

  void editNote({int? noteId}) => _router.go(AppRoutes.noteEditorPath(noteId));
}
