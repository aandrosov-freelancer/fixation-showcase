import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final notesScreenViewModelProvider = AsyncNotifierProvider(
  () => NoteEditorScreenViewModel(),
  isAutoDispose: true,
);

class NoteEditorScreenViewModel extends AsyncNotifier {
  @override
  FutureOr<dynamic> build() {
    // TODO: implement build
    throw UnimplementedError();
  }
}
