import 'package:app/core/l10n/app_localizations.dart';
import 'package:app/core/values/assets.gen.dart';
import 'package:flutter/material.dart';

class NotesScreenWidget extends StatelessWidget {
  const NotesScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const _CustomAppBar());
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);

    return Container(
      padding: const .symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: true,
        child: Row(
          children: [
            Assets.icons.appIcon.image(width: 48, height: 48),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  l10n.appSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
