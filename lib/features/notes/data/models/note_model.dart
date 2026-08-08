import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_model.freezed.dart';

@freezed
abstract class NoteModel with _$NoteModel {
  factory NoteModel({
    required int id,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NoteModel;
}
