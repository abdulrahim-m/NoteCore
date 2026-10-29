import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/rust/api.dart';
import 'package:mobile_client/features/notes/presentation/controllers/notes_controller.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/dialogs.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/group_management_sheet.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/group_picker_sheet.dart';
import 'package:mobile_client/features/notes/presentation/dialogs/tag_picker_sheet.dart';
import 'package:mobile_client/features/notes/presentation/widgets/group_slider.dart';
import 'package:mobile_client/features/notes/presentation/widgets/note_card.dart';
import 'package:mobile_client/shared/custom_search_bar.dart';
import 'package:mobile_client/features/notes/presentation/widgets/selection_bar.dart';
import 'package:mobile_client/features/notes/presentation/widgets/tags_drawer.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late final NotesController _c;

  @override
  void initState() {
    super.initState();
    final core = getIt<NoteCore>();
    _c = NotesController(notes: core.notes(), tags: core.tags());
    _c.onError = (message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    };
    _scrollController.addListener(_onScroll);
    _c.loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _c.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) _c.loadMore();
  }

  /// A filtered page can be too short to scroll; keep loading until it is.
  void _fillViewportIfNeeded() {
    if (!mounted || !_scrollController.hasClients) return;
    if (!_c.hasMore || _c.loading || _c.loadingMore) return;
    final pos = _scrollController.position;
    if (pos.hasContentDimensions && pos.maxScrollExtent <= 300) _c.loadMore();
  }

  // ------------------------------------------------------------- actions
  Future<void> _openNote(int id) async {
    await context.push('/notes/$id');
    if (mounted) _c.refresh(); // the note may have been edited or deleted
  }

  Future<void> _createNote() async {
    final note = await _c.createNote();
    if (note != null && mounted) await _openNote(note.id);
  }

  Future<void> _deleteSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.notes_delete_notes_title,
      message: l10n.notes_delete_notes_body(_c.selectedNoteIds.length),
      confirmLabel: l10n.notes_delete,
      destructive: true,
    );
    if (ok) await _c.deleteSelected();
  }

  Future<void> _changeGroup() async {
    final result = await showGroupPickerSheet(context, _c.groups);
    if (result != null) await _c.moveSelected(result.id);
  }

  Future<void> _addTags() async {
    final ids = await showTagPickerSheet(
      context,
      listenable: _c,
      tags: () => _c.tags,
      onCreate: _c.createTag,
    );
    if (ids != null) await _c.addTagsToSelected(ids);
  }

  // --------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        return PopScope(
          canPop: !_c.selecting,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _c.clearSelection();
          },
          child: Scaffold(
            key: _scaffoldKey,
            drawer: TagsDrawer(controller: _c),
            floatingActionButton: _c.selecting
                ? null
                : FloatingActionButton(
                    tooltip: l10n.notes_new_note,
                    onPressed: _createNote,
                    child: const Icon(Icons.add),
                  ),
            body: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _c.selecting
                      ? SelectionBar(
                          key: const ValueKey('selection'),
                          count: _c.selectedNoteIds.length,
                          onClose: _c.clearSelection,
                          onAddTag: _addTags,
                          onChangeGroup: _changeGroup,
                          onDelete: _deleteSelected,
                        )
                      : Column(
                          key: const ValueKey('browse'),
                          children: [
                            CustomSearchBar(
                              hint: l10n.notes_search_hint,
                              controller: _searchController,
                              onChanged: _c.setSearchText,
                              onFilterTap: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                              filterCount: _c.activeFilterCount,
                            ),
                            GroupSlider(
                              groups: _c.groups,
                              selectedId: _c.selectedGroupId,
                              onSelected: _c.selectGroup,
                              onManage: () =>
                                  showGroupManagementSheet(context, _c),
                            ),
                          ],
                        ),
                ),
                Expanded(child: _buildList(l10n)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    if (_c.loading && _c.notes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_c.notes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _c.loadInitial,
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
                      _c.isSearching ? Icons.search_off : Icons.note_add_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _c.isSearching ? l10n.notes_no_results : l10n.notes_empty,
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

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _fillViewportIfNeeded(),
    );

    return RefreshIndicator(
      onRefresh: _c.loadInitial,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 6, bottom: 88),
        itemCount: _c.notes.length + (_c.loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _c.notes.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final note = _c.notes[i];
          return NoteCard(
            key: ValueKey(note.id),
            note: note,
            selecting: _c.selecting,
            selected: _c.selectedNoteIds.contains(note.id),
            onLongPress: () => _c.toggleSelection(note.id),
            onTap: () {
              if (_c.selecting) {
                _c.toggleSelection(note.id);
              } else {
                _openNote(note.id);
              }
            },
          );
        },
      ),
    );
  }
}
