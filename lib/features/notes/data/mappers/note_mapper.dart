import 'package:app/core/database/app_database.dart';
import 'package:app/features/notes/data/models/note_model.dart';
import 'package:drift/drift.dart';

final class NoteMapper {
  NoteMapper._();

  static NoteModel toModel(NoteItem item) {
    return .new(
      id: item.id,
      title: item.title,
      content: item.content,
      summary: item.summary,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  static NoteItem toItem(NoteModel model) {
    return .new(
      id: model.id,
      title: model.title,
      content: model.content,
      summary: model.summary,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static NoteItemsCompanion toItemCompanion(NoteModel model) {
    return .new(
      title: Value(model.title),
      content: Value(model.content),
      summary: Value(model.summary),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }
}
