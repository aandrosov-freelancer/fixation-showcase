import 'package:app/core/l10n/app_localizations.dart';
import 'package:app/core/services/dialog_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/notes/presentation/screens/note_editor_screen/note_editor_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NoteEditorScreenWidget extends ConsumerWidget {
  const NoteEditorScreenWidget({super.key, this.noteId});

  final int? noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final isKeyboardOpened = MediaQuery.viewInsetsOf(context).bottom > 0;
    ref.watch(noteEditorScreenViewModelProvider(noteId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        ref
            .read(noteEditorScreenViewModelProvider(noteId).notifier)
            .saveAndExit();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _CustomAppBar(
          titleController: ref
              .read(noteEditorScreenViewModelProvider(noteId).notifier)
              .titleController,
          onExit: ref
              .read(noteEditorScreenViewModelProvider(noteId).notifier)
              .saveAndExit,
          onDelete: ref
              .read(noteEditorScreenViewModelProvider(noteId).notifier)
              .deleteNote,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: QuillEditor.basic(
                    controller: ref
                        .read(
                          noteEditorScreenViewModelProvider(noteId).notifier,
                        )
                        .contentController,
                    focusNode: ref
                        .read(
                          noteEditorScreenViewModelProvider(noteId).notifier,
                        )
                        .contentFocusNode,
                    scrollController: ref
                        .read(
                          noteEditorScreenViewModelProvider(noteId).notifier,
                        )
                        .contentScrollController,
                    config: QuillEditorConfig(
                      placeholder: l10n.contentHint,
                      expands: true,
                      padding: const EdgeInsets.only(
                        top: 12,
                        right: 20,
                        left: 20,
                        bottom: 128,
                      ),
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                    ),
                  ),
                ),
                if (isKeyboardOpened) const SizedBox(height: 80),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              alignment: Alignment.bottomRight,
              child: SafeArea(
                top: false,
                child: _FloatingQuillToolbar(
                  controller: ref
                      .read(noteEditorScreenViewModelProvider(noteId).notifier)
                      .contentController,
                  onAddImage: ref
                      .read(noteEditorScreenViewModelProvider(noteId).notifier)
                      .addImage,
                  onColorPick: () =>
                      ref.read(dialogServiceProvider).showColorPicker(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController titleController;
  final VoidCallback onExit;
  final VoidCallback onDelete;

  const _CustomAppBar({
    required this.titleController,
    required this.onExit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final customColors = context.customColors;

    return Container(
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
      child: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: colorScheme.onSurface),
          onPressed: onExit,
          tooltip: l10n.backTooltip,
        ),
        title: TextField(
          controller: titleController,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: l10n.titleHint,
            hintStyle: TextStyle(
              color: customColors.textMuted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            fillColor: Colors.transparent,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.trash2, color: colorScheme.error),
            onPressed: onDelete,
            tooltip: l10n.deleteNoteTooltip,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FloatingQuillToolbar extends StatefulWidget {
  final QuillController controller;
  final VoidCallback onAddImage;
  final Future<Color?> Function() onColorPick;

  const _FloatingQuillToolbar({
    required this.controller,
    required this.onAddImage,
    required this.onColorPick,
  });

  @override
  State<_FloatingQuillToolbar> createState() => _FloatingQuillToolbarState();
}

class _FloatingQuillToolbarState extends State<_FloatingQuillToolbar> {
  bool _isExpanded = true;

  void _toggleFormat(Attribute attribute) {
    final isToggled = widget.controller.getSelectionStyle().containsKey(
      attribute.key,
    );
    if (isToggled) {
      widget.controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      widget.controller.formatSelection(attribute);
    }
    setState(() {});
  }

  void _toggleHeader(Attribute attribute) {
    final style = widget.controller.getSelectionStyle();
    final currentHeaderAttr = style.attributes[Attribute.header.key];
    if (currentHeaderAttr != null &&
        currentHeaderAttr.value == attribute.value) {
      widget.controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      widget.controller.formatSelection(attribute);
    }
    setState(() {});
  }

  Future<void> _showColorPicker() async {
    final color = await widget.onColorPick();
    if (color == null) return;

    final hex = '#${color.toARGB32().toRadixString(16).substring(2)}';
    widget.controller.formatSelection(ColorAttribute(hex));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final style = widget.controller.getSelectionStyle();
    final isBold = style.containsKey(Attribute.bold.key);
    final isItalic = style.containsKey(Attribute.italic.key);
    final isList =
        style.containsKey(Attribute.ul.key) ||
        style.containsKey(Attribute.ol.key);
    final currentHeaderValue = style.attributes[Attribute.header.key]?.value;
    final isH1 = currentHeaderValue == 1;
    final isH2 = currentHeaderValue == 2;
    final isH3 = currentHeaderValue == 3;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isExpanded)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ToolbarButton(
                        icon: LucideIcons.bold,
                        isActive: isBold,
                        onTap: () => _toggleFormat(Attribute.bold),
                        tooltip: l10n.tooltipBold,
                      ),
                      const SizedBox(width: 4),
                      _ToolbarButton(
                        icon: LucideIcons.italic,
                        isActive: isItalic,
                        onTap: () => _toggleFormat(Attribute.italic),
                        tooltip: l10n.tooltipItalic,
                      ),
                      const SizedBox(width: 4),
                      _ToolbarButton(
                        icon: LucideIcons.heading1,
                        isActive: isH1,
                        onTap: () => _toggleHeader(Attribute.h1),
                        tooltip: l10n.tooltipHeader1,
                      ),
                      const SizedBox(width: 4),
                      _ToolbarButton(
                        icon: LucideIcons.heading2,
                        isActive: isH2,
                        onTap: () => _toggleHeader(Attribute.h2),
                        tooltip: l10n.tooltipHeader2,
                      ),
                      const SizedBox(width: 4),
                      _ToolbarButton(
                        icon: LucideIcons.heading3,
                        isActive: isH3,
                        onTap: () => _toggleHeader(Attribute.h3),
                        tooltip: l10n.tooltipHeader3,
                      ),
                      const SizedBox(width: 4),
                      _ToolbarButton(
                        icon: LucideIcons.list,
                        isActive: isList,
                        onTap: () => _toggleFormat(Attribute.ul),
                        tooltip: l10n.tooltipList,
                      ),
                      const SizedBox(width: 4),
                      _ToolbarButton(
                        icon: LucideIcons.palette,
                        isActive: false,
                        onTap: _showColorPicker,
                        tooltip: l10n.tooltipColor,
                      ),
                      const SizedBox(width: 4),
                      _ToolbarButton(
                        icon: LucideIcons.image,
                        isActive: false,
                        onTap: widget.onAddImage,
                        tooltip: l10n.tooltipImage,
                      ),
                    ],
                  ),
                ),
              ),
            _ToolbarButton(
              icon: _isExpanded
                  ? LucideIcons.chevronRight
                  : LucideIcons.slidersHorizontal,
              isActive: false,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              tooltip: _isExpanded ? l10n.tooltipCollapse : l10n.tooltipToolbar,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _ToolbarButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: isActive ? colorScheme.onPrimary : colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
