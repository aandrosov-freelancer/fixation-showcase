import 'dart:convert';

import 'package:app/core/l10n/app_localizations.dart';
import 'package:app/core/storage/local_image_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/notes/data/repositories/notes_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NoteEditorScreenWidget extends ConsumerStatefulWidget {
  final int? noteId;

  const NoteEditorScreenWidget({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreenWidget> createState() =>
      _NoteEditorScreenWidgetState();
}

class _NoteEditorScreenWidgetState
    extends ConsumerState<NoteEditorScreenWidget> {
  final TextEditingController _titleController = TextEditingController();
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  int? _noteId;
  DateTime? _noteCreatedAt;

  @override
  void initState() {
    super.initState();
    _noteId = widget.noteId;
    _quillController = QuillController.basic();
    _loadNoteData();
  }

  Future<void> _loadNoteData() async {
    final notesRepository = ref.read(notesRepositoryProvider);

    if (widget.noteId != null) {
      final note = await notesRepository.getNoteById(id: widget.noteId!);
      if (note == null) {
        return;
      }

      _titleController.text = note.title;
      _quillController.document = Document.fromJson(jsonDecode(note.content));
      _noteCreatedAt = note.createdAt;
    }
  }

  Future<void> _saveAndExit() async {
    final notesRepository = ref.read(notesRepositoryProvider);
    final title = _titleController.text;
    final content = jsonEncode(_quillController.document.toDelta().toJson());
    final summary = _quillController.document.getPlainText(0, 100);
    final createdAt = _noteCreatedAt ?? .now();
    final updatedAt = DateTime.now();

    if (_noteId == null) {
      _noteId = await notesRepository.addNote(
        .new(
          title: title,
          content: content,
          summary: summary,
          createdAt: .now(),
          updatedAt: updatedAt,
        ),
      );
    } else {
      await notesRepository.updateNote(
        .new(
          id: _noteId!,
          title: title,
          content: content,
          summary: summary,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      );
    }

    if (mounted) {
      context.pop();
    }
  }

  void _insertImageEmbed(String imagePath) {
    final index = _quillController.selection.baseOffset;
    final length = _quillController.selection.extentOffset - index;
    final validIndex = index >= 0
        ? index
        : _quillController.document.length - 1;
    final validLength = length > 0 ? length : 0;
    _quillController.replaceText(
      validIndex,
      validLength,
      BlockEmbed.image(imagePath),
      null,
    );
  }

  void _showImageSourcePicker() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final customColors = context.customColors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
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
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final savedPath =
                        await LocalImageService.pickAndSaveImageFromGallery();
                    if (savedPath != null && mounted) {
                      _insertImageEmbed(savedPath);
                    }
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
                    _showAddImageUrlDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddImageUrlDialog() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                _insertImageEmbed(url);
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
      ),
    );
  }

  void _onDeletePressed() {
    _DeleteNoteDialog.show(context, onDelete: () async {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpened = bottomInset > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _saveAndExit();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _CustomAppBar(
          titleController: _titleController,
          onExit: _saveAndExit,
          onDelete: _onDeletePressed,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: QuillEditor.basic(
                    controller: _quillController,
                    focusNode: _editorFocusNode,
                    scrollController: _scrollController,
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
                  controller: _quillController,
                  onAddImage: () {
                    _editorFocusNode.unfocus();
                    _showImageSourcePicker();
                  },
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

  const _FloatingQuillToolbar({
    required this.controller,
    required this.onAddImage,
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

  void _showColorPicker() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = ColorScheme.of(context);
    final editorPalette = context.customColors.editorPalette;

    showModalBottomSheet(
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
                    onTap: () {
                      final hex =
                          '#${color.toARGB32().toRadixString(16).substring(2)}';
                      widget.controller.formatSelection(ColorAttribute(hex));
                      Navigator.pop(sheetContext);
                      setState(() {});
                    },
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

class _DeleteNoteDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteNoteDialog({required this.onDelete});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => _DeleteNoteDialog(onDelete: onDelete),
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
