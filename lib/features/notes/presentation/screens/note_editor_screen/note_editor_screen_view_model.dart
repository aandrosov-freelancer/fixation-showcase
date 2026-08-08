import 'dart:async';

import 'package:app/features/notes/data/models/note_model.dart';
import 'package:app/features/notes/data/repositories/notes_repository.dart';
import 'package:app/features/notes/presentation/screens/notes_screen/notes_screen_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final noteEditorViewModelProvider = AsyncNotifierProvider(
  () => NoteEditorViewModel(),
  isAutoDispose: true,
);

final class NoteEditorViewModel extends AsyncNotifier<NoteModel?> {
  late final NotesRepository _notesRepository;
  Timer? _debounceTimer;

  @override
  FutureOr<NoteModel?> build() {
    _notesRepository = ref.watch(notesRepositoryProvider);
    ref.onDispose(() => _debounceTimer?.cancel());
    return null;
  }

  Future<void> loadNote(int? noteId) async {
    if (noteId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _notesRepository.getNoteById(id: noteId),
    );
  }

  Future<NoteModel> saveNote(NoteModel note, {bool debounced = false}) async {
    if (debounced) {
      _debounceTimer?.cancel();
      final completer = Completer<NoteModel>();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        try {
          final saved = await _saveNoteInternal(note);
          if (!completer.isCompleted) completer.complete(saved);
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
        }
      });
      return completer.future;
    } else {
      _debounceTimer?.cancel();
      final saved = await _saveNoteInternal(note);
      ref.invalidate(notesScreenViewModelProvider);
      return saved;
    }
  }

  Future<NoteModel> _saveNoteInternal(NoteModel note) async {
    final now = DateTime.now();
    final noteToSave = note.copyWith(updatedAt: now);

    if (noteToSave.id == 0) {
      final id = await _notesRepository.addNote(
        noteToSave.copyWith(createdAt: now),
      );
      final saved = noteToSave.copyWith(id: id, createdAt: now);
      state = AsyncData(saved);
      return saved;
    } else {
      await _notesRepository.updateNote(noteToSave);
      state = AsyncData(noteToSave);
      return noteToSave;
    }
  }

  Future<void> deleteNote() async {
    final note = state.value;
    if (note != null && note.id != 0) {
      await _notesRepository.deleteNote(id: note.id);
      ref.invalidate(notesScreenViewModelProvider);
    }
  }
}
