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

  @override
  String get titleHint => 'Заголовок';

  @override
  String get contentHint => 'Начните писать...';

  @override
  String get backTooltip => 'Назад';

  @override
  String get deleteNoteTooltip => 'Удалить заметку';

  @override
  String get imageSourceTitle => 'Добавить изображение';

  @override
  String get insertImageFromGallery => 'Выбрать из галереи';

  @override
  String get insertImageFromUrl => 'Вставить по ссылке';

  @override
  String get insertImageTitle => 'Вставить изображение';

  @override
  String get insertImageHint => 'https://example.com/image.png';

  @override
  String get insertButton => 'Вставить';

  @override
  String get textColorTitle => 'Цвет текста';

  @override
  String get tooltipBold => 'Жирный';

  @override
  String get tooltipItalic => 'Курсив';

  @override
  String get tooltipHeader1 => 'Заголовок 1';

  @override
  String get tooltipHeader2 => 'Заголовок 2';

  @override
  String get tooltipHeader3 => 'Заголовок 3';

  @override
  String get tooltipList => 'Список';

  @override
  String get tooltipColor => 'Цвет';

  @override
  String get tooltipImage => 'Изображение';

  @override
  String get tooltipCollapse => 'Свернуть';

  @override
  String get tooltipToolbar => 'Панель инструментов';
}
