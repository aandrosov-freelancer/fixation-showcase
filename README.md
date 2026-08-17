# 📝 Фиксация — Flutter Rich-Text Notes App

<p align="center">
  <img src="assets/screenshots/showcase.png" alt="Фиксация — Превью приложения" width="100%" />
</p>

<p align="center">
  <b>Современное, высокопроизводительное Flutter-приложение для ведения заметок, мыслей и идей с форматированием текста, поиском и offline-first хранением.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.44.9-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.12.2-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/State_Management-Riverpod_3-00599C?style=for-the-badge" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Database-Drift_(SQLite)-003B57?style=for-the-badge" alt="Drift" />
  <img src="https://img.shields.io/badge/Architecture-Feature--First-2E7D32?style=for-the-badge" alt="Architecture" />
  <img src="https://img.shields.io/badge/L10n-Russian-E53935?style=for-the-badge" alt="L10n" />
</p>

---

## 📌 О проекте

**«Фиксация»** — мобильное приложение на Flutter, спроектированное по принципам чистой архитектуры (**Clean Architecture**) и паттерна **Feature-First**. Проект разработан как демонстрационный пет-проект, демонстрирующий лучшие практики современной мобильной разработки на Dart & Flutter:

* Продуманное управление состоянием через **Riverpod 3** (`AsyncNotifier` + `flutter_hooks`).
* Надежное **Offline-First** хранение данных в реляционной SQLite базе данных с помощью **Drift**.
* Полноценный **Rich Text редактор** с поддержкой заголовков, списка, цветов текста и вставки изображений.
* Строгая локализация (**i18n / l10n**) без хардкода строк в UI.
* 100% иммутабельные доменные модели (**Freezed**) и разделение слоев данных (Data Mappers).

---

## ✨ Основные возможности

* **✍️ Rich Text редактирование**: Поддержка стилизации текста (жирный, курсив, заголовки H1-H3, маркированные списки, кастомный цвет текста).
* **🖼️ Работа с медиа**: Добавление изображений в заметку напрямую из галереи устройства или по URL с сохранением в локальное изолированное хранилище приложения.
* **🔍 Мгновенный поиск**: Поиск заметок в реальном времени по заголовку и содержимому с дебаунсом.
* **🎨 Адаптивный UI**: Плавная stagger-анимация появления карточек заметок (`flutter_staggered_animations`), адаптирующаяся под различные экраны.
* **🗑️ Диалоги подтверждения**: Безопасное удаление заметок через сервисный слой без передач `BuildContext`.
* **🌐 Русская локализация**: Все тексты и описания приложения вынесены в ARB-файлы (`app_ru.arb`).

---

## 🛠️ Технологический стек

| Слой / Компонент | Технологии и Библиотеки | Описание |
| :--- | :--- | :--- |
| **Фреймворк** | `Flutter 3.44.9` (FVM), `Dart SDK ^3.12.2` | Основная платформа разработки |
| **State Management** | `hooks_riverpod`, `flutter_hooks` | Управление состоянием на `AsyncNotifier` и хуках |
| **Database & Storage** | `drift`, `drift_flutter`, `path_provider` | Реактивная локальная БД SQLite и файловое хранилище |
| **Rich Text Editor** | `flutter_quill`, `flutter_quill_extensions` | Редактор форматированного текста |
| **Routing** | `go_router`, `go_transitions` | Декларативная маршрутизация и анимация переходов |
| **Code Generation** | `freezed`, `json_serializable`, `build_runner`, `flutter_gen` | Генерация иммутабельных моделей, DB-кода и ресурсов |
| **Icons & UI** | `lucide_icons_flutter`, `flutter_staggered_animations` | Современные векторные иконки и анимации |
| **Logging & Diag** | `logger`, `ProviderObserver` | Глобальный логик ошибок провайдеров и приложения |

---

## 🏛️ Архитектура проекта

В проекте реализован подраздел **Feature-First Architecture**, гарантирующий изолированность фич и масштабируемость:

```text
lib/
├── main.dart                   — Точка входа, ProviderScope, MaterialApp.router, LoggerObserver
├── core/                       — Глобальное ядро приложения
│   ├── database/               — Drift база данных (таблицы, миграции, DAO)
│   ├── l10n/                   — ARB локализации и сгенерированные классы (app_ru.arb)
│   ├── providers/              — Глобальные Riverpod провайдеры (loggerProvider)
│   ├── router/                 — Конфигурация GoRouter (AppRoutes, routerProvider)
│   ├── services/               — Абстракции сервисов (DialogService, LocalImageService)
│   ├── storage/                — Сервисы работы с файловой системой
│   ├── theme/                  — AppTheme, кастомные расширения темы (AppCustomColors)
│   └── values/                 — Сгенерированная палитра цветов и ассеты (FlutterGen)
└── features/                   — Модули функционала
    └── notes/                  — Фича заметок
        ├── data/
        │   ├── mappers/        — Mappers для конвертации сущностей DB <-> Domain models
        │   ├── models/         — Freezed-модели данных (NoteModel)
        │   └── repositories/   — Репозиторий доступа к данным (NotesRepository)
        └── presentation/
            └── screens/
                ├── note_editor_screen/  — Экран редактора заметки (Widget + ViewModel)
                └── notes_screen/        — Главный экран списка заметок (Widget + ViewModel)
```

### Архитектурные паттерны:
1. **AsyncNotifier ViewModel**: Экраны используют `AsyncNotifierProvider` для асинхронного состояния с паттерном `AsyncValue.guard()`, исключающим необработанные исключения.
2. **Data Mapping Pattern**: Сущности базы данных (`NoteItem`) не протекают в UI-слой. `NoteMapper` изолирует трансформации между Drift DB и доменной моделью `NoteModel`.
3. **Decoupled Dialog Service**: `DialogService` работает через `GlobalKey<NavigatorState>`, позволяя вызывать UI-диалоги вызовом методов сервисного слоя без прокидывания `BuildContext`.
4. **Custom Theme Extensions**: Оформление вынесено в `ThemeExtension<AppCustomColors>`, обеспечивая безопасную типизацию цветов и адаптацию под темы.

---

## 🚀 Запуск и сборка

### Предварительные требования
* **FVM** (Flutter Version Management) — рекомендуется
* **Flutter**: `3.44.9`
* **Dart SDK**: `^3.12.2`

### 1. Клонирование и установка зависимостей
```bash
git clone https://github.com/your-username/fixation-app-riverpod.git
cd fixation-app-riverpod

# Загрузка зависимостей через FVM
fvm flutter pub get
```

### 2. Генерация кода
Проект использует `build_runner` для генерации кода Drift, Freezed и FlutterGen:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

### 3. Запуск приложения
```bash
fvm flutter run
```

---

## 🧹 Качество кода и форматирование

Код строго соответствует рекомендациям Dart Linter и правилам проекта:

```bash
# Форматирование кода
fvm dart format .

# Статический анализ
fvm flutter analyze
```

---