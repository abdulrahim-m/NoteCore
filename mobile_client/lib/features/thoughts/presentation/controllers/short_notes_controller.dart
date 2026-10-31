import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:mobile_client/core/rust/api/short_notes.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/core/rust/dto/short_note.dart';
import 'package:mobile_client/shared/controllers/paged_list_controller.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';

/// The list of thought sections, paging + selection come from the base class,
/// search/filter values from the shared [SearchFilters].
class ShortNotesController
    extends PagedListController<ShortNoteSectionListItemDto> {
  ShortNotesController({
    required ShortNotesApi api,
    required this.filters,
  }) : _api = api {
    filters.queryChanges.addListener(_onQueryChanged);
  }

  final ShortNotesApi _api;
  final SearchFilters filters;

  bool _grid = true;
  bool get grid => _grid;

  void toggleGrid() {
    _grid = !_grid;
    notifyListeners();
  }

  void _onQueryChanged() => reload();

  @override
  int idOf(ShortNoteSectionListItemDto item) => item.id;

  @override
  Future<List<ShortNoteSectionListItemDto>> fetchPage(ListRequestDto req) {
    return filters.isSearching
        ? _api.search(params: filters.toParams(), req: req)
        : _api.getAllSections(req: req);
  }

  Future<ShortNoteSectionDto?> createSection(String name) async {
    ShortNoteSectionDto? created;
    await guard(() async {
      created = await _api.createSection(
        name: name.trim(),
        tagIds: Int64List(0),
      );
    });
    return created;
  }

  Future<void> renameSelected(String name) async {
    if (selectedIds.length != 1) return;
    final ok = await guard(
      () => _api.updateSectionName(id: selectedIds.first, name: name.trim()),
    );
    if (ok) clearSelection();
    await reload(keepPages: true);
  }

  Future<void> deleteSelected() async {
    final ids = selectedIds.toList();
    await guard(() async {
      for (final id in ids) {
        await _api.deleteSection(id: id, force: true);
      }
    });
    clearSelection();
    await reload(keepPages: true);
  }

  Future<void> addTagsToSelected(Set<int> tagIds) async {
    if (tagIds.isEmpty || !selecting) return;
    final targets = items.where((s) => selectedIds.contains(s.id)).toList();
    final ok = await guard(() async {
      for (final s in targets) {
        final merged = {...s.tags.map((t) => t.id), ...tagIds};
        if (merged.length == s.tags.length) continue; // nothing new
        await _api.updateSectionTags(
          sectionId: s.id,
          tagIds: Int64List.fromList(merged.toList()),
        );
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
