import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api.dart';
import 'package:mobile_client/features/notes/presentation/controllers/note_editor_controller.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/dialogs.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/group_picker_sheet.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/tag_picker_sheet.dart';
import 'package:mobile_client/features/notes/presentation/markdown/markdown_editing.dart';
import 'package:mobile_client/shared/text_direction_utils.dart';
import 'package:mobile_client/features/notes/presentation/widgets/markdown_toolbar.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key, required this.noteId});

  final int noteId;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with WidgetsBindingObserver {
  late final NoteEditorController _ed;
  final _titleCtl = TextEditingController();
  final _contentCtl = MarkdownTextController();
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();
  final _undo = UndoHistoryController();

  bool _ready = false;
  bool _forceLeave = false;
  bool _hadFocusOnPointerDown = false;
  String _lastTitle = '';
  String _lastContent = '';

  /// Direction of each editor from how its text starts, null = use the app's.
  TextDirection? _titleDir;
  TextDirection? _contentDir;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final core = getIt<NoteCore>();
    _ed = NoteEditorController(
      noteId: widget.noteId,
      notes: core.notes(),
      tags: core.tags(),
    );
    _ed.onError = _showMessage;
    _load();
  }

  Future<void> _load() async {
    await _ed.load();
    if (!mounted || _ed.loadFailed) return;

    // Fill the fields *before* listening, so loading is never seen as an edit.
    _titleCtl.text = _ed.initialTitle;
    _contentCtl.text = MarkdownCodec.fromMarkdown(_ed.initialContent);
    _lastTitle = _titleCtl.text;
    _lastContent = _contentCtl.text;
    _titleDir = detectTextDirection(_lastTitle);
    _contentDir = detectTextDirection(_lastContent);
    _titleCtl.addListener(_onChanged);
    _contentCtl.addListener(_onChanged);
    setState(() => _ready = true);

    if (_ed.isFresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _titleFocus.requestFocus();
      });
    }
  }

  void _onChanged() {
    final title = _titleCtl.text;
    final content = _contentCtl.text;
    // Selection changes also notify, only react to real text edits.
    if (title == _lastTitle && content == _lastContent) return;
    _lastTitle = title;
    _lastContent = content;

    final titleDir = detectTextDirection(title);
    final contentDir = detectTextDirection(content);
    if (titleDir != _titleDir || contentDir != _contentDir) {
      setState(() {
        _titleDir = titleDir;
        _contentDir = contentDir;
      });
    }

    _ed.edit(title: title, content: _contentCtl.markdown);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _ed.flush();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ed.onError = null;
    _ed.dispose(); // writes anything still unsaved
    _titleCtl.dispose();
    _contentCtl.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    _undo.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- actions
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleBack() async {
    final ok = await _ed.flush();
    if (!mounted) return;
    if (!ok && !_forceLeave) {
      // Don't silently lose the edit: the second back press leaves anyway.
      _forceLeave = true;
      _showMessage(AppLocalizations.of(context)!.note_leave_failed);
      return;
    }
    context.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.note_delete_title,
      message: l10n.note_delete_body,
      confirmLabel: l10n.notes_delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    if (await _ed.delete() && mounted) context.pop();
  }

  void _share() {
    final title = _titleCtl.text.trim();
    final body = _contentCtl.markdown.trim();
    if (title.isEmpty && body.isEmpty) return;
    SharePlus.instance.share(
      ShareParams(
        text: title.isEmpty ? body : (body.isEmpty ? title : '$title\n\n$body'),
        subject: title.isEmpty ? null : title,
      ),
    );
  }

  Future<void> _pickGroup() async {
    final result = await showGroupPickerSheet(
      context,
      _ed.groups,
      markCurrent: true,
      currentId: _ed.groupId,
    );
    if (result != null && result.id != _ed.groupId) {
      await _ed.moveToGroup(result.id);
    }
  }

  Future<void> _editTags() async {
    final l10n = AppLocalizations.of(context)!;
    final ids = await showTagPickerSheet(
      context,
      listenable: _ed,
      tags: () => _ed.allTags,
      onCreate: _ed.createTag,
      initial: _ed.tags.map((t) => t.id).toSet(),
      title: l10n.notes_tags,
      allowEmpty: true,
    );
    if (ids != null) await _ed.setTags(ids);
  }

  Future<void> _removeTag(int id) async {
    await _ed.setTags(_ed.tags.map((t) => t.id).toSet()..remove(id));
  }

  /// Tapping a ☐/☑ glyph flips it.
  void _onContentTap() {
    final toggled = _contentCtl.toggleCheckboxAtCaret();
    // Ticking an item while just reading shouldn't leave the keyboard open.
    if (toggled && !_hadFocusOnPointerDown) _contentFocus.unfocus();
  }

  // --------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: ListenableBuilder(
        listenable: _ed,
        builder: (context, _) {
          return Scaffold(
            appBar: AppBar(
              title: _ready ? _StatusLabel(status: _ed.status) : null,
              actions: _ready
                  ? [
                      IconButton(
                        tooltip: l10n.note_share,
                        onPressed: _share,
                        icon: const Icon(Icons.share_outlined),
                      ),
                      IconButton(
                        tooltip: l10n.notes_delete,
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ]
                  : null,
            ),
            body: _buildBody(l10n),
          );
        },
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_ed.loadFailed) {
      return Center(child: Text(l10n.note_load_failed));
    }
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final appDirection = Directionality.of(context);
    final titleDirection = _titleDir ?? appDirection;
    final contentDirection = _contentDir ?? appDirection;

    final titleStyle = (theme.textTheme.headlineMedium ?? const TextStyle())
        .copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface);
    final bodyStyle = (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontSize: 16,
      height: 1.55,
      color: cs.onSurface,
    );

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Make the editor at least as tall as the screen so a tap on the
              // empty area below the text still focuses it.
              final minLines = math.max(
                8,
                ((constraints.maxHeight - 150) / (16 * 1.55)).floor(),
              );
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleCtl,
                      focusNode: _titleFocus,
                      textDirection: titleDirection,
                      style: titleStyle,
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [
                        FilteringTextInputFormatter.singleLineFormatter,
                      ],
                      onSubmitted: (_) => _contentFocus.requestFocus(),
                      decoration: InputDecoration(
                        hintText: l10n.note_title_hint,
                        hintStyle: titleStyle.copyWith(color: cs.outline),
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.all(5)
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildMeta(l10n),
                    const SizedBox(height: 14),
                    Listener(
                      onPointerDown: (_) =>
                          _hadFocusOnPointerDown = _contentFocus.hasFocus,
                      child: TextField(
                        controller: _contentCtl,
                        focusNode: _contentFocus,
                        undoController: _undo,
                        textDirection: contentDirection,
                        style: bodyStyle,
                        minLines: minLines,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        inputFormatters: [MarkdownInputFormatter()],
                        scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        onTap: _onContentTap,
                        decoration: InputDecoration(
                          hintText: l10n.note_content_hint,
                          hintStyle: bodyStyle.copyWith(color: cs.outline),
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.all(5)
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ListenableBuilder(
          listenable: _contentFocus,
          builder: (context, _) => _contentFocus.hasFocus
              ? MarkdownToolbar(
                  controller: _contentCtl,
                  undo: _undo,
                  focusNode: _contentFocus,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMeta(AppLocalizations l10n) {
    final groupId = _ed.groupId;
    final groupName = groupId == null
        ? l10n.notes_unassigned
        : (_ed.groups.where((g) => g.id == groupId).firstOrNull?.name ??
              l10n.notes_unassigned);

    return Wrap(
      spacing: 6,
      runSpacing: 0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ActionChip(
          visualDensity: VisualDensity.compact,
          avatar: const Icon(Icons.folder_outlined, size: 18),
          label: Text(groupName),
          onPressed: _pickGroup,
        ),
        for (final tag in _ed.tags)
          InputChip(
            visualDensity: VisualDensity.compact,
            label: Text(tag.name),
            onPressed: _editTags,
            onDeleted: () => _removeTag(tag.id),
          ),
        ActionChip(
          visualDensity: VisualDensity.compact,
          avatar: const Icon(Icons.add, size: 18),
          label: Text(l10n.notes_add_tag),
          onPressed: _editTags,
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});
  final SaveStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final (text, color) = switch (status) {
      SaveStatus.saved => (l10n.note_saved, cs.outline),
      SaveStatus.pending => (l10n.note_unsaved, cs.outline),
      SaveStatus.saving => (l10n.note_saving, cs.outline),
      SaveStatus.error => (l10n.note_save_failed, cs.error),
    };
    return Text(
      text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color),
    );
  }
}
