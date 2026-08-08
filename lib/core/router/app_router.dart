import 'package:app/core/router/app_routes.dart';
import 'package:app/features/notes/presentation/screens/note_editor_screen/note_editor_screen_widget.dart';
import 'package:app/features/notes/presentation/screens/notes_screen/notes_screen_widget.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'notes',
        builder: (context, state) => const NotesScreenWidget(),
      ),
      GoRoute(
        path: AppRoutes.noteEditorParam,
        name: 'note_editor',
        builder: (context, state) {
          final idParam = state.pathParameters['id'];
          final noteId = (idParam == null || idParam == AppRoutes.newNoteId)
              ? null
              : int.tryParse(idParam);
          return NoteEditorScreenWidget(noteId: noteId);
        },
      ),
    ],
  );
}
