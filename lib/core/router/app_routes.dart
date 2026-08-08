class AppRoutes {
  static const String home = '/';
  static const String noteEditorParam = '/note/:id';
  static const String newNoteId = 'new';

  static String noteEditorPath(dynamic id) => '/note/$id';
}
