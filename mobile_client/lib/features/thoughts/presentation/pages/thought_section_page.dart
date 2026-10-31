import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api/short_notes.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/tag_picker_sheet.dart';
import 'package:mobile_client/features/thoughts/presentation/controllers/short_note_section_controller.dart';
import 'package:mobile_client/shared/auto_save_text_field.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/dialogs.dart';
import 'package:mobile_client/shared/search_filters.dart';
import 'package:mobile_client/shared/text_direction_utils.dart';

class ThoughtSectionPage extends StatefulWidget {
  const ThoughtSectionPage({super.key, required this.sectionId});

  final int sectionId;

  @override
  State<ThoughtSectionPage> createState() => _ThoughtSectionPageState();
}

class _ThoughtSectionPageState extends State<ThoughtSectionPage> {
  late final ShortNoteSectionController _c;
  late final SearchFilters _filters;
  final _composer = TextEditingController();
  final _composerFocus = FocusNode();
  final _scroll = ScrollController();
  TextDirection? _composerDir;

  @override
  void initState() {
    super.initState();
    _filters = getIt<SearchFilters>();
    _c = ShortNoteSectionController(
      sectionId: widget.sectionId,
      api: getIt<ShortNotesApi>(),
    );
    _c.onError = _showMessage;
    _filters.loadTags();
    _c.load();
  }

  @override
  void dispose() {
    _c.dispose();
    _composer.dispose();
    _composerFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // -------------------------------------------------------------- actions
  Future<void> _add() async {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    _composer.clear();
    setState(() => _composerDir = null);
    await _c.addItem(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _editTags() async {
    final l10n = AppLocalizations.of(context)!;
    final ids = await showTagPickerSheet(
      context,
      listenable: _filters,
      tags: () => _filters.tags,
      onCreate: _filters.createTag,
      initial: _c.tags.map((t) => t.id).toSet(),
      title: l10n.notes_tags,
      allowEmpty: true,
    );
    if (ids != null) await _c.setTags(ids, _filters.tags);
  }

  Future<void> _removeTag(int id) =>
      _c.setTags(_c.tags.map((t) => t.id).toSet()..remove(id), _filters.tags);

  Future<void> _deleteSection() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.thoughts_delete_title(1),
      message: l10n.thoughts_delete_body(1),
      confirmLabel: l10n.notes_delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    if (await _c.deleteSection() && mounted) context.pop();
  }

  // ---------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            actions: _c.loading || _c.failed
                ? null
                : [
                    IconButton(
                      tooltip: l10n.notes_delete,
                      onPressed: _deleteSection,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
          ),
          body: _c.loading
              ? const Center(child: CircularProgressIndicator())
              : _c.failed
              ? Center(child: Text(l10n.thoughts_load_failed))
              : Column(
                  children: [
                    Expanded(child: _buildList(l10n)),
                    _buildComposer(l10n),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final items = _c.items;

    final titleStyle = (theme.textTheme.headlineMedium ?? const TextStyle())
        .copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface);
    final bodyStyle = (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontSize: 16,
      height: 1.4,
      color: cs.onSurface,
    );

    Widget swipeBackground(AlignmentGeometry alignment) => Container(
      color: cs.errorContainer,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
    );

    return ListView.builder(
      controller: _scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return _buildHeader(l10n, titleStyle);

        final item = items[i - 1];
        return Dismissible(
          key: ValueKey(item.id),
          background: swipeBackground(AlignmentDirectional.centerStart),
          secondaryBackground: swipeBackground(AlignmentDirectional.centerEnd),
          onDismissed: (_) => _c.deleteItem(item.id),
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: 9,
                          end: 12,
                        ),
                        child: Icon(Icons.circle, size: 6, color: cs.primary),
                      ),
                      Expanded(
                        child: AutoSaveTextField(
                          initialText: item.content,
                          onSave: (text) => _c.updateItem(item.id, text),
                          onEmptyUnfocus: () => _c.deleteItem(item.id),
                          decoration: InputDecoration(
                            hintStyle: bodyStyle,
                            isDense: true,
                            contentPadding: EdgeInsets.all(0),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations l10n, TextStyle titleStyle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSaveTextField(
            initialText: _c.name,
            onSave: _c.rename,
            decoration: InputDecoration(
                hintText: l10n.thoughts_section_name,
                hintStyle: titleStyle,
              ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in _c.tags)
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
          ),
          if (_c.items.isEmpty) ...[
            const SizedBox(height: 32),
            Center(
              child: Text(
                l10n.thoughts_section_empty,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComposer(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _composer,
                    focusNode: _composerFocus,
                    textDirection: _composerDir,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.sentences,
                    // onEditingComplete (not onSubmitted) keeps the keyboard
                    // open so several thoughts can be added in a row.
                    onEditingComplete: _add,
                    onChanged: (t) {
                      final dir = detectTextDirection(t);
                      if (dir != _composerDir) setState(() => _composerDir = dir);
                    },
                    decoration: InputDecoration(
                      hintText: l10n.thoughts_new_item_hint,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.thoughts_add,
                  onPressed: _add,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
