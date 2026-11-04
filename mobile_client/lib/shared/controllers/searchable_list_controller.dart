import 'package:flutter/foundation.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/shared/controllers/paged_list_controller.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';

/// A paged list driven by the app-wide [SearchFilters],
/// with the bulk actions every list shares: delete and add tags to the
/// selection. Subclasses only map them onto their Rust API.
abstract class SearchableListController<T> extends PagedListController<T> {
  SearchableListController(this.filters) {
    filters.queryChanges.addListener(onQueryChanged);
  }

  final SearchFilters filters;

  List<TagDto> tagsOf(T item);

  Future<List<T>> listRemote(ListRequestDto req);
  Future<List<T>> searchRemote(SearchParamsDto params, ListRequestDto req);
  Future<void> deleteRemote(int id);

  Future<void> setTagsRemote(int id, Int64List tagIds);

  @protected
  void onQueryChanged() => reload();

  @override
  Future<List<T>> fetchPage(ListRequestDto req) => filters.isSearching
      ? searchRemote(filters.toParams(), req)
      : listRemote(req);

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

  /// Adds [tagIds] to every selected item, keeping the tags they have
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
    filters.queryChanges.removeListener(onQueryChanged);
    super.dispose();
  }
}
