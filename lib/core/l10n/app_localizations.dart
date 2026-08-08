import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// Название приложения
  ///
  /// In ru, this message translates to:
  /// **'Фиксация'**
  String get appName;

  /// Подзаголовок приложения
  ///
  /// In ru, this message translates to:
  /// **'Заметки, идеи, мысли'**
  String get appSubtitle;

  /// Текст по умолчанию для пустой карточки заметки
  ///
  /// In ru, this message translates to:
  /// **'Без дополнительного текста'**
  String get noDescription;

  /// Подсказка в поле поиска
  ///
  /// In ru, this message translates to:
  /// **'Поиск по заметкам...'**
  String get searchHint;

  /// Заголовок для пустого списка заметок
  ///
  /// In ru, this message translates to:
  /// **'Заметок пока нет'**
  String get emptyNotesTitle;

  /// Подсказка для пустого списка заметок
  ///
  /// In ru, this message translates to:
  /// **'Нажмите \"+\", чтобы создать свою первую заметку'**
  String get emptyNotesSubtitle;

  /// Заголовок при отсутствии результатов поиска
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get emptySearchTitle;

  /// Подсказка при отсутствии результатов поиска
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить поисковый запрос'**
  String get emptySearchSubtitle;

  /// Заголовок ошибки загрузки
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка при загрузке заметок'**
  String get loadErrorTitle;

  /// Подсказка при ошибке загрузки
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте перезапустить приложение.'**
  String get loadErrorSubtitle;

  /// Кнопка повтора
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retryButton;

  /// Заголовок диалога удаления
  ///
  /// In ru, this message translates to:
  /// **'Удалить заметку?'**
  String get deleteDialogTitle;

  /// Текст диалога подтверждения удаления
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить эту заметку? Это действие невозможно отменить.'**
  String get deleteDialogMessage;

  /// Кнопка удалить
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteButton;

  /// Кнопка отмена
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancelButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
