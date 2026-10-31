import 'dart:async';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:mobile_client/core/rust/api/short_tasks.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/core/rust/dto/short_task.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';
import 'package:mobile_client/shared/controllers/section_list_controller.dart';

/// The list of checklists. Sections come with their items, so ticking is
/// applied locally right away (and written to the core in the background).
///
/// By default only unfinished work is shown: ticked items and finished
/// sections stay visible for a moment (so the change is seen), then fade out.
/// [showCompleted] reveals everything.
class ShortTasksController extends SectionListController<ShortTaskSectionDto> {
  ShortTasksController({
    required ShortTasksApi api,
    required SearchFilters filters,
  }) : _api = api,
       super(filters);

  static const _itemLinger = Duration(milliseconds: 700);
  static const _collapseAfter = Duration(milliseconds: 700);
  static const _sectionLinger = Duration(milliseconds: 1400);

  final ShortTasksApi _api;

  bool _showCompleted = false;
  final Set<int> _expanded = {};
  final Set<int> _lingerItems = {};
  final Set<int> _lingerSections = {};
  final Map<String, Timer> _timers = {};

  /// A section with items that are all done.
  static bool isComplete(ShortTaskSectionDto s) =>
      s.items.isNotEmpty && s.items.every((i) => i.done);

  // ------------------------------------------------------------- view state
  bool get showCompleted => _showCompleted;

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  bool isExpanded(int id) => _expanded.contains(id);

  void toggleExpanded(int id) {
    if (!_expanded.add(id)) _expanded.remove(id);
    notifyListeners();
  }

  List<ShortTaskSectionDto> get visibleSections => _showCompleted
      ? items
      : items
            .where((s) => !isComplete(s) || _lingerSections.contains(s.id))
            .toList();

  List<ShortTaskItemDto> visibleItems(ShortTaskSectionDto s) => _showCompleted
      ? s.items
      : s.items.where((i) => !i.done || _lingerItems.contains(i.id)).toList();

  // ---------------------------------------------------------------- ticking
  Future<void> toggleItem(int sectionId, int itemId) async {
    final section = _section(sectionId);
    final item = section?.items.where((i) => i.id == itemId).firstOrNull;
    if (section == null || item == null) return;

    final nowDone = !item.done;
    _setDone(sectionId, itemId, nowDone);

    if (nowDone) {
      _afterTick(sectionId, itemId);
    } else {
      _cancel('i$itemId');
      _lingerItems.remove(itemId);
      _cancel('s$sectionId');
      _cancel('c$sectionId');
      _lingerSections.remove(sectionId);
      notifyListeners();
    }

    try {
      final done = await _api.toggleItemDone(id: itemId);
      if (done != nowDone) _setDone(sectionId, itemId, done);
    } catch (e) {
      _setDone(sectionId, itemId, !nowDone); // revert
      report(e);
    }
  }

  void _afterTick(int sectionId, int itemId) {
    if (_showCompleted) return;
    _later('i$itemId', _itemLinger, () => _lingerItems.remove(itemId));
    _lingerItems.add(itemId);

    final s = _section(sectionId);
    if (s != null && isComplete(s)) {
      _lingerSections.add(sectionId);
      _later('c$sectionId', _collapseAfter, () => _expanded.remove(sectionId));
      _later('s$sectionId', _sectionLinger, () {
        _lingerSections.remove(sectionId);
        for (final i in s.items) {
          _lingerItems.remove(i.id);
        }
      });
    }
  }

  void _later(String key, Duration d, void Function() fn) {
    _cancel(key);
    _timers[key] = Timer(d, () {
      _timers.remove(key);
      fn();
      notifyListeners();
    });
  }

  void _cancel(String key) => _timers.remove(key)?.cancel();

  ShortTaskSectionDto? _section(int id) =>
      items.where((s) => s.id == id).firstOrNull;

  void _setDone(int sectionId, int itemId, bool done) => updateWhere(
    (s) => s.id == sectionId,
    (s) => ShortTaskSectionDto(
      id: s.id,
      title: s.title,
      listedItems: s.listedItems,
      tags: s.tags,
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
      items: [
        for (final i in s.items)
          i.id == itemId
              ? ShortTaskItemDto(
                  id: i.id,
                  sectionId: i.sectionId,
                  text: i.text,
                  done: done,
                )
              : i,
      ],
    ),
  );

  // ------------------------------------------------------ section list hooks
  @override
  int idOf(ShortTaskSectionDto item) => item.id;
  @override
  String titleOf(ShortTaskSectionDto item) => item.title;
  @override
  List<TagDto> tagsOf(ShortTaskSectionDto item) => item.tags;

  @override
  Future<List<ShortTaskSectionDto>> listRemote(ListRequestDto req) =>
      _api.getAllSections(req: req);

  @override
  Future<List<ShortTaskSectionDto>> searchRemote(
    SearchParamsDto params,
    ListRequestDto req,
  ) => _api.search(params: params, req: req);

  @override
  Future<int> createRemote(String title) async =>
      (await _api.createSection(title: title, tagIds: Int64List(0))).id;

  @override
  Future<void> renameRemote(int id, String title) =>
      _api.updateSectionTitle(id: id, title: title);

  @override
  Future<void> deleteRemote(int id) => _api.deleteSection(id: id, force: true);

  @override
  Future<void> setTagsRemote(int id, Int64List tagIds) =>
      _api.updateSectionTags(sectionId: id, tagIds: tagIds);

  @override
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    super.dispose();
  }
}
