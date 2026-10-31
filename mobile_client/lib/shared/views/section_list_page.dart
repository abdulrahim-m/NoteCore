import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/custom_search_bar.dart';
import 'package:mobile_client/shared/dialogs.dart';
import 'package:mobile_client/shared/search_filters.dart';
import 'package:mobile_client/shared/section_list_controller.dart';
import 'package:mobile_client/shared/section_selection_actions.dart';
import 'package:mobile_client/shared/selection_bar.dart';
import 'package:mobile_client/shared/tags_drawer.dart';

/// Tab page for a list of sections (Thoughts, Checklists): shared search bar +
/// tag drawer, long-press selection bar, create FAB, pull to refresh, paging.
/// Pages only provide the controller and how the content looks ([slivers]).
class SectionListPage<C extends SectionListController<T>, T>
    extends StatefulWidget {
  const SectionListPage({
    super.key,
    required this.create,
    required this.routeOf,
    required this.slivers,
    required this.visibleCount,
    required this.emptyText,
    required this.emptyIcon,
    required this.searchHint,
    required this.newTitle,
    required this.nameHint,
    required this.renameTitle,
    required this.deleteTitle,
    required this.deleteBody,
    this.toolbar,
  });

  final C Function(SearchFilters filters) create;

  /// Route of a section's page, e.g. `/thoughts/7`.
  final String Function(int id) routeOf;

  /// The content slivers; [open] opens a section's page.
  final List<Widget> Function(
    BuildContext context,
    C controller,
    void Function(int id) open,
  )
  slivers;

  /// How many sections are actually shown (may be fewer than loaded).
  final int Function(C controller) visibleCount;

  /// Text of the empty state when not searching.
  final String Function(C controller) emptyText;
  final IconData emptyIcon;

  /// Optional row under the search bar (view toggles, filters, ...).
  final Widget Function(BuildContext context, C controller)? toolbar;

  final String searchHint;
  final String newTitle;
  final String nameHint;
  final String renameTitle;
  final String Function(int count) deleteTitle;
  final String Function(int count) deleteBody;

  @override
  State<SectionListPage<C, T>> createState() => _SectionListPageState<C, T>();
}

class _SectionListPageState<C extends SectionListController<T>, T>
    extends State<SectionListPage<C, T>> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scroll = ScrollController();
  late final SearchFilters _filters;
  late final C _c;

  @override
  void initState() {
    super.initState();
    _filters = getIt<SearchFilters>();
    _c = widget.create(_filters);
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

  /// A short page may not be scrollable (or may show nothing because the rest
  /// is hidden); keep loading until it is.
  void _fillViewportIfNeeded() {
    if (!mounted || !_c.hasMore || _c.loading || _c.loadingMore) return;
    if (widget.visibleCount(_c) == 0) {
      _c.loadMore();
      return;
    }
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.hasContentDimensions && pos.maxScrollExtent <= 300) _c.loadMore();
  }

  // -------------------------------------------------------------- actions
  Future<void> _open(int id) async {
    await context.push(widget.routeOf(id));
    if (mounted) _c.reload(keepPages: true); // name / count / tags may differ
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showTextInputDialog(
      context,
      title: widget.newTitle,
      hint: widget.nameHint,
      confirmLabel: l10n.notes_create,
    );
    if (name == null) return;
    final id = await _c.createSection(name);
    if (id != null && mounted) await _open(id);
  }

  // ---------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    // Every tab has its own FAB; without a null hero tag
                    // Flutter throws "multiple heroes share the same tag"
                    // when a page is pushed on top of the tab shell.
                    heroTag: null,
                    tooltip: widget.newTitle,
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
                          actions: buildSectionSelectionActions<T>(
                            context,
                            controller: _c,
                            renameTitle: widget.renameTitle,
                            nameHint: widget.nameHint,
                            deleteTitle: widget.deleteTitle,
                            deleteBody: widget.deleteBody,
                          ),
                        )
                      : Column(
                          key: const ValueKey('browse'),
                          children: [
                            CustomSearchBar(
                              hint: widget.searchHint,
                              controller: _filters.textController,
                              // the shared controller already drives the search
                              onChanged: (_) {},
                              onFilterTap: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                              filterCount: _filters.activeFilterCount,
                            ),
                            if (widget.toolbar != null)
                              widget.toolbar!(context, _c),
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

    WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewportIfNeeded());

    if (widget.visibleCount(_c) == 0) {
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
                      searching ? Icons.search_off : widget.emptyIcon,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      searching ? l10n.notes_no_results : widget.emptyText(_c),
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

    // One scrollable whatever the layout (only the slivers change), so
    // toggling grid/list never attaches the controller to two scroll views.
    return RefreshIndicator(
      onRefresh: _c.reload,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ...widget.slivers(context, _c, _open),
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
