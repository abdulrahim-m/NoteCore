import 'dart:async';

import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/api/tags.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/shared/utils/api_guard.dart';
import 'package:mobile_client/shared/controllers/filterable_controller.dart';

/// The search/filter state of the app.
///
/// Every list page shares it, the same search text, tag filters, date
/// filters and tag list. Pages put [textController] in their search 
/// bar and listen to [queryChanges] to reload, so text typed on one
/// page is already applied on the next.
///
/// It is also the [FilterableListController] that `TagsDrawer` edits.
class SearchFilters extends ChangeNotifier
    with ApiGuard
    implements FilterableListController {
  SearchFilters(this._tagsApi) {
    _lastText = textController.text;
    textController.addListener(_onText);
  }

  final TagsApi _tagsApi;

  /// This must be used in every search bar so the text is shared too.
  final TextEditingController textController = TextEditingController();

  final ValueNotifier<int> _query = ValueNotifier(0);
  final Set<int> _filterTagIds = {};
  List<TagDto> _tags = [];
  DateTime? _createdAfter;
  DateTime? _createdBefore;
  String _lastText = '';
  Timer? _debounce;

  /// Fires (debounced for typing) whenever the *query* changes, i.e. when
  /// lists must be reloaded. Does not fire for plain tag-list loads.
  Listenable get queryChanges => _query;

  String get text => textController.text.trim();

  @override
  List<TagDto> get tags => _tags;
  @override
  Set<int> get filterTagIds => _filterTagIds;
  @override
  DateTime? get createdAfter => _createdAfter;
  @override
  DateTime? get createdBefore => _createdBefore;

  @override
  int get activeFilterCount =>
      _filterTagIds.length +
      (_createdAfter != null ? 1 : 0) +
      (_createdBefore != null ? 1 : 0);

  bool get isSearching => text.isNotEmpty || activeFilterCount > 0;

  SearchParamsDto toParams() => SearchParamsDto(
    text: text.isEmpty ? null : text,
    tags: _filterTagIds.isEmpty
        ? null
        : Int64List.fromList(_filterTagIds.toList()),
    createdAfter: _createdAfter,
    createdBefore: _createdBefore,
  );

  // ----------------------------------------------------------------- text
  void _onText() {
    if (textController.text == _lastText) return;
    _lastText = textController.text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _bump);
  }

  void _bump() => _query.value++;

  void _changed() {
    notifyListeners();
    _bump();
  }

  // -------------------------------------------------------------- filters
  @override
  void toggleFilterTag(int id) {
    if (!_filterTagIds.add(id)) _filterTagIds.remove(id);
    _changed();
  }

  @override
  void setCreatedAfter(DateTime? value) {
    _createdAfter = value;
    _changed();
  }

  @override
  void setCreatedBefore(DateTime? value) {
    _createdBefore = value;
    _changed();
  }

  @override
  void clearFilters() {
    _filterTagIds.clear();
    _createdAfter = null;
    _createdBefore = null;
    _changed();
  }

  // ----------------------------------------------------------------- tags
  Future<void> loadTags() async {
    final ok = await guard(() async {
      _tags = await _tagsApi.getList();
      _filterTagIds.removeWhere((id) => !_tags.any((t) => t.id == id));
    });
    if (ok) notifyListeners();
  }

  @override
  Future<TagDto?> createTag(String name) async {
    TagDto? created;
    final ok = await guard(() async {
      created = await _tagsApi.createTag(name: name.trim());
    });
    if (ok) await loadTags();
    return created;
  }

  /// Deleting a tag changes every list's tags, so lists reload.
  @override
  Future<void> deleteTag(int id) async {
    final ok = await guard(() => _tagsApi.deleteTag(id: id));
    if (!ok) return;
    _filterTagIds.remove(id);
    await loadTags();
    _bump();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    textController.dispose();
    _query.dispose();
    super.dispose();
  }
}
