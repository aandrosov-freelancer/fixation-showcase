import 'dart:async';
import 'dart:convert';

import 'package:app/core/router/app_router.dart';
import 'package:app/core/services/dialog_service.dart';
import 'package:app/core/storage/local_image_service.dart';
import 'package:app/features/notes/data/repositories/notes_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:truncate/truncate.dart';

final noteEditorScreenViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<NoteEditorScreenViewModel, void, int?>(
      NoteEditorScreenViewModel.new,
    );

class NoteEditorScreenViewModel extends AsyncNotifier<void> {
  NoteEditorScreenViewModel(this._noteId);

  late final TextEditingController titleController;
  late final QuillController contentController;
  late final FocusNode contentFocusNode;
  late final ScrollController contentScrollController;

  late final GoRouter _router;
  late final DialogService _dialogService;
  late final NotesRepository _notesRepository;

  int? _noteId;
  DateTime? _noteCreatedAt;

  @override
  FutureOr<void> build() async {
    titleController = TextEditingController();
    contentController = QuillController.basic();
    contentFocusNode = FocusNode();
    contentScrollController = ScrollController();

    _router = ref.watch(routerProvider);
    _dialogService = ref.watch(dialogServiceProvider);
    _notesRepository = ref.watch(notesRepositoryProvider);

    ref.onDispose(titleController.dispose);
    ref.onDispose(contentController.dispose);
    ref.onDispose(contentFocusNode.dispose);
    ref.onDispose(contentScrollController.dispose);

    await _loadNoteData();
  }

  Future<void> _loadNoteData() async {
    if (_noteId != null) {
      final note = await _notesRepository.getNoteById(id: _noteId!);
      if (note == null) {
        return;
      }

      titleController.text = note.title;
      contentController.document = Document.fromJson(jsonDecode(note.content));
      _noteCreatedAt = note.createdAt;
    }
  }

  Future<void> saveAndExit() async {
    final title = titleController.text;
    final content = jsonEncode(contentController.document.toDelta().toJson());
    final summary = truncate(contentController.document.toPlainText(), 40);
    final createdAt = _noteCreatedAt ?? .now();
    final updatedAt = DateTime.now();

    if (_noteId == null) {
      _noteId = await _notesRepository.addNote(
        .new(
          title: title,
          content: content,
          summary: summary,
          createdAt: .now(),
          updatedAt: updatedAt,
        ),
      );
    } else {
      await _notesRepository.updateNote(
        .new(
          id: _noteId!,
          title: title,
          content: content,
          summary: summary,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      );
    }

    _router.pop();
  }

  Future<void> deleteNote() async {
    Future<void> delete() async {
      state = .loading();
      state = await .guard(() async {
        if (_noteId != null) await _notesRepository.deleteNote(id: _noteId!);
        _router.pop();
      });
    }

    _dialogService.showDeleteNoteDialog(onDelete: delete);
  }

  Future<void> addImage() async {
    void insertImageFromGallery() async {
      final path = await LocalImageService.pickAndSaveImageFromGallery();
      if (path != null) _insertImageEmbed(path);
    }

    void insertImageFromUrl(String url) {
      if (url.isNotEmpty) _insertImageEmbed(url);
    }

    _dialogService.showImageSourcePicker(
      onInsertImageFromGallery: insertImageFromGallery,
      onInsertImageFromUrl: () => _dialogService.showAddImageUrlDialog(
        onInsertImage: insertImageFromUrl,
      ),
    );
  }

  void _insertImageEmbed(String imagePath) {
    final index = contentController.selection.baseOffset;
    final length = contentController.selection.extentOffset - index;
    final validIndex = index >= 0
        ? index
        : contentController.document.length - 1;
    final validLength = length > 0 ? length : 0;
    contentController.replaceText(
      validIndex,
      validLength,
      BlockEmbed.image(imagePath),
      null,
    );
  }
}
