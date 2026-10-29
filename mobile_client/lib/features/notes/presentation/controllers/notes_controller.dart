import 'dart:async';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart'; 

import 'package:flutter/foundation.dart';
import 'package:mobile_client/core/rust/api/notes.dart';
import 'package:mobile_client/core/rust/api/tags.dart';
import 'package:mobile_client/core/rust/dto/note.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/core/rust/error.dart';

/// State + actions for the notes list (groups, tags, search, filters,
/// selection). The UI listens to it and never talks to the Rust API directly.
class NotesController extends ChangeNotifier {
  NotesController({required NotesApi notes, required TagsApi tags})
    : _notesApi = notes,
      _tagsApi = tags;

  static const int pageSize = 20;

  final NotesApi _notesApi;
  final TagsApi _tagsApi;

  /// Set by the page so errors can be shown as a snackbar.
  void Function(String message)? onError;

  // ---------------------------------------------------------------- state
  List<NoteListItemDto> _notes = [];
  List<NoteGroupDto> _groups = [];
  List<TagDto> _tags = [];

  int? _selectedGroupId; // null => "All"
  String _searchText = '';
  final Set<int> _filterTagIds = {};
  DateTime? _createdAfter;
  DateTime? _createdBefore;

  final Set<int> _selectedNoteIds = {};

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  int _token = 0; // invalidates stale loads
  Timer? _debounce;

  List<NoteListItemDto> get notes => _notes;
  List<NoteGroupDto> get groups => _groups;
  List<TagDto> get tags => _tags;
  int? get selectedGroupId => _selectedGroupId;
  String get searchText => _searchText;
  Set<int> get filterTagIds => _filterTagIds;
  DateTime? get createdAfter => _createdAfter;
  DateTime? get createdBefore => _createdBefore;
  Set<int> get selectedNoteIds => _selectedNoteIds;
  bool get selecting => _selectedNoteIds.isNotEmpty;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;

  bool get isSearching =>
      _searchText.trim().isNotEmpty ||
      _filterTagIds.isNotEmpty ||
      _createdAfter != null ||
      _createdBefore != null;

  /// Number of active filters shown on the filter button badge,
  /// the text search is visible in its own field.
  int get activeFilterCount =>
      _filterTagIds.length +
      (_createdAfter != null ? 1 : 0) +
      (_createdBefore != null ? 1 : 0);

  // -------------------------------------------------------------- loading
  Future<void> loadInitial() async {
    await Future.wait([loadGroups(), loadTags(), reload()]);
  }

  Future<void> loadGroups() async {
    await _guard(() async {
      final list = await _notesApi.getGroups();
      list.sort((a, b) => a.placing.compareTo(b.placing));
      _groups = list;
      // The selected group may have vanished.
      if (_selectedGroupId != null &&
          !_groups.any((g) => g.id == _selectedGroupId)) {
        _selectedGroupId = null;
      }
      notifyListeners();
    });
  }

  Future<void> loadTags() async {
    await _guard(() async {
      _tags = await _tagsApi.getList();
      _filterTagIds.removeWhere((id) => !_tags.any((t) => t.id == id));
      notifyListeners();
    });
  }

  Future<void> reload() async {
    final token = ++_token;
    _loading = true;
    _loadingMore = false;
    _hasMore = true;
    _page = 1;
    notifyListeners();
    try {
      final items = await _fetch(1);
      if (token != _token) return;
      _notes = items;
      _hasMore = !isSearching && items.length >= pageSize;
      _selectedNoteIds.removeWhere((id) => !_notes.any((n) => n.id == id));
    } catch (e) {
      if (token == _token) _report(e);
    } finally {
      if (token == _token) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final token = _token;
    _loadingMore = true;
    notifyListeners();
    try {
      final items = await _fetch(_page + 1);
      if (token != _token) return;
      _page += 1;
      _notes = [..._notes, ...items];
      _hasMore = items.length >= pageSize;
    } catch (e) {
      if (token == _token) _report(e);
    } finally {
      if (token == _token) {
        _loadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<List<NoteListItemDto>> _fetch(int page) async {
    final req = ListRequestDto(currentPage: page, limit: pageSize);
    if (isSearching) {
      final text = _searchText.trim();
      final results = await _notesApi.search(
        params: SearchParamsDto(
          text: text.isEmpty ? null : text,
          tags: _filterTagIds.isEmpty ? null : _ids(_filterTagIds),
          createdAfter: _createdAfter,
          createdBefore: _createdBefore,
        ),
        list: req
      );
      if (_selectedGroupId == null) return results;
      return results.where((n) => n.groupId == _selectedGroupId).toList();
    }

    if (_selectedGroupId == null) {
      return _notesApi.getList(req: req);
    }
    return _notesApi.getListInGroup(req: req, groupId: _selectedGroupId!);
  }

  // ------------------------------------------------- group / filter state
  void selectGroup(int? id) {
    if (_selectedGroupId == id) return;
    _selectedGroupId = id;
    _selectedNoteIds.clear();
    reload();
  }

  void setSearchText(String text) {
    _searchText = text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), reload);
    notifyListeners();
  }

  void toggleFilterTag(int id) {
    if (!_filterTagIds.add(id)) _filterTagIds.remove(id);
    reload();
  }

  void setCreatedAfter(DateTime? value) {
    _createdAfter = value;
    reload();
  }

  void setCreatedBefore(DateTime? value) {
    _createdBefore = value;
    reload();
  }

  void clearFilters() {
    _filterTagIds.clear();
    _createdAfter = null;
    _createdBefore = null;
    reload();
  }

  // ------------------------------------------------------------ selection
  void toggleSelection(int id) {
    if (!_selectedNoteIds.add(id)) _selectedNoteIds.remove(id);
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedNoteIds.isEmpty) return;
    _selectedNoteIds.clear();
    notifyListeners();
  }

  // --------------------------------------------------------- note actions
  /// Creates an empty note in the current group, if one is selected.
  Future<NoteDto?> createNote() async {
    NoteDto? created;
    final ok = await _guard(() async {
      final note = await _notesApi.createNote();
      created = note;
      final group = _selectedGroupId;
      if (group != null) {
        await _notesApi.addToGroup(groupId: group, noteIds: _ids([note.id]));
      }
    });
    if (ok) await Future.wait([reload(), loadGroups()]);
    return created;
  }

  Future<void> deleteSelected() async {
    final ids = _selectedNoteIds.toList();
    if (ids.isEmpty) return;
    await _guard(() async {
      for (final id in ids) {
        await _notesApi.deleteNote(id: id);
      }
    });
    _selectedNoteIds.clear();
    await Future.wait([reload(), loadGroups()]);
  }

  /// [groupId] == null removes the notes from any group.
  Future<void> moveSelected(int? groupId) async {
    final ids = _selectedNoteIds.toList();
    if (ids.isEmpty) return;
    final ok = await _guard(
      () => _notesApi.addToGroup(groupId: groupId, noteIds: _ids(ids)),
    );
    if (ok) _selectedNoteIds.clear();
    await Future.wait([reload(), loadGroups()]);
  }

  /// Adds [tagIds] to every selected note, keeping the tags they already have,
  /// the API replaces the whole set, so we merge first.
  Future<void> addTagsToSelected(Set<int> tagIds) async {
    if (tagIds.isEmpty || _selectedNoteIds.isEmpty) return;
    final targets = _notes.where((n) => _selectedNoteIds.contains(n.id));
    final ok = await _guard(() async {
      for (final note in targets.toList()) {
        final merged = {...note.tags.map((t) => t.id), ...tagIds};
        if (merged.length == note.tags.length) continue;
        await _notesApi.updateTags(noteId: note.id, tagIds: _ids(merged));
      }
    });
    if (ok) _selectedNoteIds.clear();
    await reload();
  }

  // -------------------------------------------------------- group actions
  Future<void> createGroup(String name) async {
    final placing = _groups.isEmpty
        ? 0
        : _groups.map((g) => g.placing).reduce((a, b) => a > b ? a : b) + 1;
    final ok = await _guard(
      () => _notesApi.createNoteGroup(name: name.trim(), placing: placing),
    );
    if (ok) await loadGroups();
  }

  Future<void> renameGroup(int id, String name) async {
    final ok = await _guard(
      () => _notesApi.updateNoteGroup(id: id, name: name.trim()),
    );
    if (ok) await loadGroups();
  }

  /// The core refuses with 'Forbidden' if the group still contains notes, the
  /// message is surfaced through [onError].
  Future<void> deleteGroup(int id) async {
    final ok = await _guard(() => _notesApi.deleteGroup(id: id));
    if (!ok) return;
    final wasSelected = _selectedGroupId == id;
    if (wasSelected) _selectedGroupId = null;
    await loadGroups();
    if (wasSelected) await reload();
  }

  // --------------------------------------------------------- tag actions
  Future<TagDto?> createTag(String name) async {
    TagDto? created;
    final ok = await _guard(() async {
      created = await _tagsApi.createTag(name: name.trim());
    });
    if (ok) await loadTags();
    return created;
  }

  Future<void> deleteTag(int id) async {
    final ok = await _guard(() => _tagsApi.deleteTag(id: id));
    if (!ok) return;
    _filterTagIds.remove(id);
    await loadTags();
    await reload();
  }

  // -------------------------------------------------------------- helpers
  Int64List _ids(Iterable<int> ids) => Int64List.fromList(ids.toList());

  void _report(Object e) =>
      onError?.call(e is ApiError ? e.message : e.toString());

  Future<bool> _guard(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (e) {
      _report(e);
      return false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
