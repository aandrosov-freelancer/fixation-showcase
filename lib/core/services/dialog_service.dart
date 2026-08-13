import 'package:app/core/l10n/app_localizations.dart';
import 'package:app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final dialogServiceProvider = Provider<DialogService>(
  (ref) => DialogService(navigatorKey: ref.watch(navigatorKeyProvider)),
);

final class DialogService {
  DialogService({required this._navigatorKey});

  final GlobalKey<NavigatorState> _navigatorKey;

  Future<void> showDeleteNoteDialog({Function? onDelete}) async {
    showDialog(
      context: _navigatorKey.currentContext!,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final colorScheme = ColorScheme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: colorScheme.surface,
          title: Row(
            children: [
              Icon(LucideIcons.trash2, color: colorScheme.error, size: 22),
              const SizedBox(width: 10),
              Text(
                l10n.deleteDialogTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.deleteDialogMessage,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.secondary,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.cancelButton),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.deleteButton),
            ),
          ],
        );
      },
    );
  }
}
