import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

final loggerProvider = Provider<Logger>(
  (_) => throw UnimplementedError('Inject logger into the provider'),
);
