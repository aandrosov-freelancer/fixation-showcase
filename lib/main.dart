import 'package:app/core/l10n/app_localizations.dart';
import 'package:app/core/providers/logger_provider.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

final class AppProviderLoggerObserver extends ProviderObserver {
  AppProviderLoggerObserver({required this._logger});

  final Logger _logger;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _logger.e(
      'Provider failed',
      time: .now(),
      error: error,
      stackTrace: stackTrace,
    );
    super.providerDidFail(context, error, stackTrace);
  }
}

void main() {
  final logger = Logger();

  runApp(
    ProviderScope(
      overrides: [loggerProvider.overrideWithValue(logger)],
      observers: [AppProviderLoggerObserver(logger: logger)],
      child: Consumer(
        builder: (_, ref, child) => MaterialApp.router(
          routerConfig: ref.watch(routerProvider),
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (_, child) => child!,
          supportedLocales: const [Locale('ru')],
        ),
      ),
    ),
  );
}
