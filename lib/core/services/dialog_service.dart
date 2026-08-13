import 'package:app/core/l10n/app_localizations.dart';
import 'package:app/core/router/app_router.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final dialogServiceProvider = Provider<DialogService>(
  (ref) => DialogService(navigatorKey: ref.watch(navigatorKeyProvider)),
);

final class DialogService {
  DialogService({required this._navigatorKey});

  final GlobalKey<NavigatorState> _navigatorKey;

  Future<void> showDeleteNoteDialog({Function? onDelete}) async {
    await showDialog(
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

  Future<void> showAddImageUrlDialog({
    required Function(String) onInsertImage,
  }) async {
    await showDialog(
      context: _navigatorKey.currentContext!,
      builder: (dialogContext) => HookConsumer(
        builder: (context, _, _) {
          final l10n = AppLocalizations.of(context)!;
          final colorScheme = ColorScheme.of(context);
          final urlController = useTextEditingController();

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.insertImageTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            content: TextField(
              controller: urlController,
              decoration: InputDecoration(hintText: l10n.insertImageHint),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancelButton),
              ),
              ElevatedButton(
                onPressed: () {
                  final url = urlController.text.trim();
                  if (url.isNotEmpty) {
                    onInsertImage(url);
                  }
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(l10n.insertButton),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Color?> showColorPicker() async {
    final context = _navigatorKey.currentContext!;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final editorPalette = context.customColors.editorPalette;

    return showModalBottomSheet<Color>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.textColorTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: editorPalette.map((color) {
                  return GestureDetector(
                    onTap: () => Navigator.pop(sheetContext, color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showImageSourcePicker({
    required Function() onInsertImageFromGallery,
    required Function() onInsertImageFromUrl,
  }) async {
    await showModalBottomSheet(
      context: _navigatorKey.currentContext!,
      backgroundColor: ColorScheme.of(_navigatorKey.currentContext!).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => HookConsumer(
        builder: (context, _, _) {
          final l10n = AppLocalizations.of(context)!;
          final colorScheme = ColorScheme.of(context);
          final customColors = context.customColors;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      l10n.imageSourceTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: customColors.containerFill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.image,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(l10n.insertImageFromGallery),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onInsertImageFromGallery();
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: customColors.containerFill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.link,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(l10n.insertImageFromUrl),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onInsertImageFromUrl();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
