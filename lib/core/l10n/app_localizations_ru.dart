// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Фиксация';

  @override
  String get appSubtitle => 'Заметки, идеи, мысли';

  @override
  String get noDescription => 'Без дополнительного текста';

  @override
  String get searchHint => 'Поиск по заметкам...';

  @override
  String get emptyNotesTitle => 'Заметок пока нет';

  @override
  String get emptyNotesSubtitle =>
      'Нажмите \"+\", чтобы создать свою первую заметку';

  @override
  String get emptySearchTitle => 'Ничего не найдено';

  @override
  String get emptySearchSubtitle => 'Попробуйте изменить поисковый запрос';

  @override
  String get loadErrorTitle => 'Произошла ошибка при загрузке заметок';

  @override
  String get loadErrorSubtitle => 'Попробуйте перезапустить приложение.';

  @override
  String get retryButton => 'Повторить';

  @override
  String get deleteDialogTitle => 'Удалить заметку?';

  @override
  String get deleteDialogMessage =>
      'Вы уверены, что хотите удалить эту заметку? Это действие невозможно отменить.';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get cancelButton => 'Отмена';
}
