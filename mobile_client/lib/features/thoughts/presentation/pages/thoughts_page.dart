import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api/short_notes.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/tag_picker_sheet.dart';
import 'package:mobile_client/features/thoughts/presentation/controllers/short_notes_controller.dart';
import 'package:mobile_client/features/thoughts/presentation/widgets/section_card.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/widgets/custom_search_bar.dart';
import 'package:mobile_client/shared/dialogs/dialogs.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';
import 'package:mobile_client/shared/widgets/selection_bar.dart';
import 'package:mobile_client/shared/widgets/tags_drawer.dart';

class ThoughtsPage extends StatefulWidget {
  const ThoughtsPage({super.key});

  @override
  State<ThoughtsPage> createState() => _ThoughtsPageState();
}

class _ThoughtsPageState extends State<ThoughtsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scroll = ScrollController();
  late final SearchFilters _filters;
  late final ShortNotesController _c;

  @override
  void initState() {
    super.initState();
    _filters = getIt<SearchFilters>();
    _c = ShortNotesController(api: getIt<ShortNotesApi>(), filters: _filters);
    _c.onError = _showMessage;
    _filters.onError = _showMessage;
    _scroll.addListener(_onScroll);
    _filters.loadTags();
    _c.reload(); // uses whatever search is already typed on another page
  }

  @override
  void dispose() {
    _scroll.dispose();
    _c.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) _c.loadMore();
  }

  /// A short first page may not be scrollable, keep loading until it is.
  void _fillViewportIfNeeded() {
    if (!mounted || !_scroll.hasClients) return;
    if (!_c.hasMore || _c.loading || _c.loadingMore) return;
    final pos = _scroll.position;
    if (pos.hasContentDimensions && pos.maxScrollExtent <= 300) _c.loadMore();
  }

  // -------------------------------------------------------------- actions
  Future<void> _open(int id) async {
    await context.push('/thoughts/$id');
    if (mounted) _c.reload(keepPages: true);
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showTextInputDialog(
      context,
      title: l10n.thoughts_new_section,
      hint: l10n.thoughts_section_name,
      confirmLabel: l10n.notes_create,
    );
    if (name == null) return;
    final section = await _c.createSection(name);
    if (section != null && mounted) await _open(section.id);
  }

  Future<void> _renameSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final current = _c.items.firstWhere((s) => s.id == _c.selectedIds.first);
    final name = await showTextInputDialog(
      context,
      title: l10n.thoughts_rename_section,
      hint: l10n.thoughts_section_name,
      confirmLabel: l10n.notes_save,
      initial: current.name,
    );
    if (name != null && name != current.name) await _c.renameSelected(name);
  }

  Future<void> _addTags() async {
    final ids = await showTagPickerSheet(
      context,
      listenable: _filters,
      tags: () => _filters.tags,
      onCreate: _filters.createTag,
    );
    if (ids != null) await _c.addTagsToSelected(ids);
  }

  Future<void> _deleteSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final count = _c.selectedIds.length;
    final ok = await showConfirmDialog(
      context,
      title: l10n.thoughts_delete_title(count),
      message: l10n.thoughts_delete_body(count),
      confirmLabel: l10n.notes_delete,
      destructive: true,
    );
    if (ok) await _c.deleteSelected();
  }

  // ---------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: Listenable.merge([_c, _filters]),
      builder: (context, _) {
        return PopScope(
          canPop: !_c.selecting,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _c.clearSelection();
          },
          child: Scaffold(
            key: _scaffoldKey,
            drawer: TagsDrawer(controller: _filters),
            floatingActionButton: _c.selecting
                ? null
                : FloatingActionButton(
                    heroTag: null,
                    tooltip: l10n.thoughts_new_section,
                    onPressed: _create,
                    child: const Icon(Icons.add),
                  ),
            body: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _c.selecting
                      ? SelectionBar(
                          key: const ValueKey('selection'),
                          count: _c.selectedIds.length,
                          onClose: _c.clearSelection,
                          actions: [
                            if (_c.selectedIds.length == 1)
                              IconButton(
                                tooltip: l10n.thoughts_rename_section,
                                onPressed: _renameSelected,
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            IconButton(
                              tooltip: l10n.notes_add_tag,
                              onPressed: _addTags,
                              icon: const Icon(Icons.label_outline),
                            ),
                            IconButton(
                              tooltip: l10n.notes_delete,
                              onPressed: _deleteSelected,
                              icon: Icon(Icons.delete_outline, color: cs.error),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('browse'),
                          children: [
                            CustomSearchBar(
                              hint: l10n.thoughts_search_hint,
                              controller: _filters.textController,
                              onChanged: (_) {},
                              onFilterTap: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                              filterCount: _filters.activeFilterCount,
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                child: IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: _c.grid
                                      ? l10n.thoughts_list_view
                                      : l10n.thoughts_grid_view,
                                  onPressed: _c.toggleGrid,
                                  icon: Icon(
                                    _c.grid
                                        ? Icons.view_agenda_outlined
                                        : Icons.grid_view,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                Expanded(child: _buildBody(l10n)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_c.loading && _c.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_c.items.isEmpty) {
      final searching = _filters.isSearching;
      return RefreshIndicator(
        onRefresh: _c.reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 280,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      searching ? Icons.search_off : Icons.lightbulb_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      searching ? l10n.notes_no_results : l10n.thoughts_empty,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewportIfNeeded());

    Widget cardAt(int i) {
      final s = _c.items[i];
      return SectionCard(
        key: ValueKey(s.id),
        section: s,
        compact: _c.grid,
        selecting: _c.selecting,
        selected: _c.selectedIds.contains(s.id),
        onLongPress: () => _c.toggleSelection(s.id),
        onTap: () => _c.selecting ? _c.toggleSelection(s.id) : _open(s.id),
      );
    }

    return RefreshIndicator(
      onRefresh: _c.reload,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(_c.grid ? 8 : 0, 4, _c.grid ? 8 : 0, 88),
            sliver: _c.grid
                ? SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: SectionCard.gridExtent,
                        ),
                    itemCount: _c.items.length,
                    itemBuilder: (_, i) => cardAt(i),
                  )
                : SliverList.builder(
                    itemCount: _c.items.length,
                    itemBuilder: (_, i) => cardAt(i),
                  ),
          ),
          if (_c.loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
        ],
      ),
    );
  }
}
