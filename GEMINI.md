# Fixation — Flutter Notes App

Flutter-приложение для создания и редактирования заметок с rich-text редактором.

## Технологии

- **Flutter** 3.44.9 (FVM)
- **Dart SDK** ^3.12.2
- **State Management**: Riverpod (`hooks_riverpod`) + Flutter Hooks (`flutter_hooks`)
- **Database**: Drift (SQLite) с FTS5 полнотекстовым поиском
- **Routing**: GoRouter (`go_router`)
- **Code Generation**: Freezed, JsonSerializable, Drift, FlutterGen
- **Rich Text**: Flutter Quill (`flutter_quill`, `flutter_quill_extensions`)
- **Localization**: `flutter_localizations` + `intl`, шаблон — `app_ru.arb`
- **Icons**: Lucide Icons (`lucide_icons_flutter`)

## Архитектура проекта

Feature-based архитектура с разделением на core и features.

```
lib/
├── main.dart
├── core/
│   ├── database/        — Drift база данных, таблицы, сгенерированный код
│   ├── l10n/            — ARB-файлы и сгенерированные локализации
│   ├── providers/       — Глобальные Riverpod-провайдеры (logger)
│   ├── router/          — GoRouter конфигурация и маршруты
│   ├── services/        — Сервисы (DialogService, LocalImageService)
│   ├── storage/         — Работа с файловой системой
│   ├── theme/           — AppTheme, AppCustomColors, ThemeExtension
│   └── values/          — FlutterGen: сгенерированные assets и colors
└── features/
    └── <feature_name>/
        ├── data/
        │   ├── mappers/       — Маппинг между DB-сущностями и моделями
        │   ├── models/        — Freezed-модели данных
        │   └── repositories/  — Репозитории для доступа к данным
        └── presentation/
            └── screens/
                └── <screen_name>/
                    ├── <screen_name>_view_model.dart
                    └── <screen_name>_widget.dart
```

## Паттерны и соглашения

### Именование файлов

- `snake_case` для всех файлов
- Виджеты экранов: `<screen_name>_widget.dart`
- ViewModel: `<screen_name>_view_model.dart`
- Модели: `<name>_model.dart`
- Маппер: `<name>_mapper.dart`
- Репозитории: `<name>_repository.dart`

### State Management (Riverpod)

- Провайдеры объявлять как top-level `final` переменные
- ViewModel наследовать от `AsyncNotifier` с `AsyncNotifierProvider`
- ViewModel — `final class`
- Зависимости в ViewModel получать через `ref.watch()` в методе `build()`
- Использовать `AsyncValue.guard()` для безопасного обновления состояния

```dart
final notesScreenViewModelProvider = AsyncNotifierProvider(
  NotesScreenViewModel.new,
  isAutoDispose: true,
);

final class NotesScreenViewModel extends AsyncNotifier<List<NoteModel>> {
  late final NotesRepository _notesRepository;

  @override
  FutureOr<List<NoteModel>> build() async {
    _notesRepository = ref.watch(notesRepositoryProvider);
    return await _notesRepository.allNotes;
  }
}
```

### Модели данных

- Использовать Freezed с `@freezed` + `sealed class`
- Маппер — `final class` с приватным конструктором и статическими методами (`toModel`, `toItem`, `toItemCompanion`)

### Сервисы

- Сервисы создаются через Riverpod `Provider`
- `DialogService` использует `GlobalKey<NavigatorState>` для показа диалогов без BuildContext
- UI-виджеты внутри диалогов используют `HookConsumer`

### Тема

- Цвета определены в `assets/colors/colors.xml` и сгенерированы через FlutterGen в `ColorName`
- Кастомные цвета — через `ThemeExtension<AppCustomColors>`
- Доступ к кастомным цветам: `context.customColors`

### Локализация

- Все строки — в `lib/core/l10n/app_ru.arb`
- Доступ: `AppLocalizations.of(context)!`
- Поддерживаемая локаль: `ru`

### Routing

- Маршруты — статические строки в `AppRoutes`
- Конфигурация роутера — в `routerProvider` (Riverpod Provider)
- Навигация через `GoRouter` (push/go)

### Code Generation

Для генерации кода запускать:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Генерируемые файлы: `*.freezed.dart`, `*.g.dart`, `assets.gen.dart`, `colors.gen.dart`

## Запуск

```bash
fvm flutter run
```

## Форматирование и анализ

```bash
fvm dart format .
fvm flutter analyze
```
