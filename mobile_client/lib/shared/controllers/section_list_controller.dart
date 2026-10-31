import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/shared/paged_list_controller.dart';
import 'package:mobile_client/shared/search_filters.dart';

/// A paged, searchable list of *sections* (thoughts, checklists, ...) with the
/// same management actions: create, rename, delete, add tags. Subclasses only
/// map those actions onto their Rust API.
///
/// Search text / tag / date filters come from the app-wide [SearchFilters];
/// the list reloads whenever they change.
abstract class SectionListController<T> extends PagedListController<T> {
  SectionListController(this.filters) {
    filters.queryChanges.addListener(_onQueryChanged);
  }

  final SearchFilters filters;

  String titleOf(T item);
  List<TagDto> tagsOf(T item);

  Future<List<T>> listRemote(ListRequestDto req);
  Future<List<T>> searchRemote(SearchParamsDto params, ListRequestDto req);

  /// Creates an empty section and returns its id.
  Future<int> createRemote(String title);
  Future<void> renameRemote(int id, String title);
  Future<void> deleteRemote(int id);

  /// Replaces the section's tags with exactly [tagIds].
  Future<void> setTagsRemote(int id, Int64List tagIds);

  void _onQueryChanged() => reload();

  @override
  Future<List<T>> fetchPage(ListRequestDto req) => filters.isSearching
      ? searchRemote(filters.toParams(), req)
      : listRemote(req);

  /// Returns the new section's id (null on error).
  Future<int?> createSection(String title) async {
    int? id;
    await guard(() async {
      id = await createRemote(title.trim());
    });
    return id;
  }

  /// Renames the single selected section.
  Future<void> renameSelected(String title) async {
    if (selectedIds.length != 1) return;
    final id = selectedIds.first;
    final ok = await guard(() => renameRemote(id, title.trim()));
    if (ok) clearSelection();
    await reload(keepPages: true);
  }

  /// Deletes the selected sections together with their items.
  Future<void> deleteSelected() async {
    final ids = selectedIds.toList();
    await guard(() async {
      for (final id in ids) {
        await deleteRemote(id);
      }
    });
    clearSelection();
    await reload(keepPages: true);
  }

  /// Adds [tagIds] to every selected section, keeping the tags they have
  /// (the API replaces the whole set, so we merge first).
  Future<void> addTagsToSelected(Set<int> tagIds) async {
    if (tagIds.isEmpty || !selecting) return;
    final targets = items.where((s) => selectedIds.contains(idOf(s))).toList();
    final ok = await guard(() async {
      for (final s in targets) {
        final current = tagsOf(s).map((t) => t.id).toSet();
        final merged = {...current, ...tagIds};
        if (merged.length == current.length) continue; // nothing new
        await setTagsRemote(idOf(s), Int64List.fromList(merged.toList()));
      }
    });
    if (ok) clearSelection();
    await reload(keepPages: true);
  }

  @override
  void dispose() {
    filters.queryChanges.removeListener(_onQueryChanged);
    super.dispose();
  }
}
