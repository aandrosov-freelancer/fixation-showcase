import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_model.freezed.dart';

@freezed
sealed class NoteModel with _$NoteModel {
  factory NoteModel({
    @Default(0) int id,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NoteModel;
}
