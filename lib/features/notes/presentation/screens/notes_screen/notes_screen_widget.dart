import 'dart:async';

import 'package:app/core/l10n/app_localizations.dart';
import 'package:app/core/router/app_routes.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/values/assets.gen.dart';
import 'package:app/features/notes/presentation/screens/notes_screen/notes_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotesScreenWidget extends StatelessWidget {
  const NotesScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _CustomAppBarWidget(),
      body: Column(
        children: [
          Expanded(child: const _BodyWidget()),
          const _CustomBottomBarWidget(),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final DateTime updatedAt;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NoteCard({
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.onTap,
    required this.onLongPress,
  });

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final customColors = context.customColors;

    final displayTitle = title.trim().isNotEmpty
        ? title.trim()
        : _formatDate(updatedAt);

    final displayDescription = content.trim().isNotEmpty
        ? content.trim()
        : l10n.noDescription;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayDescription,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: content.trim().isNotEmpty
                          ? colorScheme.secondary
                          : customColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _formatDate(updatedAt),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: customColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyWidget extends ConsumerWidget {
  const _BodyWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ColorScheme.of(context);
    final notes = ref.watch(notesScreenViewModelProvider);

    return switch (notes) {
      AsyncValue(hasError: true) => _ErrorWidget(),
      AsyncValue(:final value, hasValue: true) => AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: value!.length,
          itemBuilder: (context, index) {
            final note = value[index];

            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: _NoteCard(
                    title: note.title,
                    content: note.content,
                    updatedAt: note.updatedAt,
                    onTap: () =>
                        context.push(AppRoutes.noteEditorPath(note.id)),
                    onLongPress: () => DeleteNoteDialog.show(
                      context,
                      onDelete: () => ref
                          .read(notesScreenViewModelProvider.notifier)
                          .deleteNote(id: note.id),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      _ => Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          strokeWidth: 2.5,
        ),
      ),
    };
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.circleAlert, color: colorScheme.error, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.loadErrorTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.loadErrorSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colorScheme.secondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteNoteDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteNoteDialog({super.key, required this.onDelete});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DeleteNoteDialog(onDelete: onDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            onDelete();
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
  }
}

class _CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const _CustomAppBarWidget();

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
        bottom: false,
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

class _CustomBottomBarWidget extends HookConsumerWidget {
  const _CustomBottomBarWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notesScreenViewModelProvider);

    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final searchTextEditingController = useTextEditingController();

    final searchTextFieldWidget = TextField(
      controller: searchTextEditingController,
      onChanged: (val) => ref
          .read(notesScreenViewModelProvider.notifier)
          .searchNotes(query: val),
      style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: l10n.searchHint,
        hintStyle: TextStyle(color: colorScheme.secondary, fontSize: 14),
        prefixIcon: Icon(
          LucideIcons.search,
          size: 18,
          color: colorScheme.secondary,
        ),
        suffixIcon: searchTextEditingController.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  LucideIcons.x,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                onPressed: () {
                  searchTextEditingController.clear();
                  ref
                      .read(notesScreenViewModelProvider.notifier)
                      .searchNotes(query: null);
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        filled: true,
        fillColor: const Color(0xFFF4F4F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );

    final addButtonWidget = IconButton.filled(
      onPressed: () => context.push(AppRoutes.noteEditorPath(null)),
      iconSize: 32,
      icon: Icon(LucideIcons.plus),
    );

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outline, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: searchTextFieldWidget),
            const SizedBox(width: 12),
            addButtonWidget,
          ],
        ),
      ),
    );
  }
}
