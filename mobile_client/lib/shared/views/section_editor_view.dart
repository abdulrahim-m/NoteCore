import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/tag_picker_sheet.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/dialogs/dialogs.dart';
import 'package:mobile_client/shared/widgets/item_composer.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';
import 'package:mobile_client/shared/controllers/section_editor_controller.dart';
import 'package:mobile_client/shared/widgets/section_header.dart';

/// Full page for one open section, shared by Thoughts and Checklists: delete
/// action, editable name + tags, the items (built by [itemBuilder]) and a
/// composer to add more. Owns (creates and disposes) its controller.
class SectionEditorView<C extends SectionEditorController<I>, I>
    extends StatefulWidget {
  const SectionEditorView({
    super.key,
    required this.create,
    required this.itemBuilder,
    required this.nameHint,
    required this.emptyMessage,
    required this.composerHint,
    required this.addTooltip,
    required this.loadFailed,
    required this.deleteTitle,
    required this.deleteBody,
  });

  final C Function() create;
  final Widget Function(BuildContext context, C controller, I item)
  itemBuilder;
  final String nameHint;
  final String emptyMessage;
  final String composerHint;
  final String addTooltip;
  final String loadFailed;
  final String deleteTitle;
  final String deleteBody;

  @override
  State<SectionEditorView<C, I>> createState() =>
      _SectionEditorViewState<C, I>();
}

class _SectionEditorViewState<C extends SectionEditorController<I>, I>
    extends State<SectionEditorView<C, I>> {
  late final C _c;
  late final SearchFilters _filters;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _filters = getIt<SearchFilters>();
    _c = widget.create();
    _c.onError = _showMessage;
    _filters.loadTags();
    _c.load();
  }

  @override
  void dispose() {
    _c.dispose();
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
  Future<void> _add(String text) async {
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
      title: widget.deleteTitle,
      message: widget.deleteBody,
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
              ? Center(child: Text(widget.loadFailed))
              : Column(
                  children: [
                    Expanded(child: _buildList()),
                    ItemComposer(
                      hint: widget.composerHint,
                      sendTooltip: widget.addTooltip,
                      onAdd: _add,
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildList() {
    final items = _c.items;
    return ListView.builder(
      controller: _scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return SectionHeader(
            name: _c.name,
            nameHint: widget.nameHint,
            tags: _c.tags,
            onRename: _c.rename,
            onEditTags: _editTags,
            onRemoveTag: _removeTag,
            emptyMessage: items.isEmpty ? widget.emptyMessage : null,
          );
        }
        return widget.itemBuilder(context, _c, items[i - 1]);
      },
    );
  }
}
