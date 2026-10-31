import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:mobile_client/core/rust/api/short_tasks.dart';
import 'package:mobile_client/core/rust/dto/short_task.dart';
import 'package:mobile_client/shared/section_editor_controller.dart';

/// One open checklist; the editing logic lives in the base class.
class ShortTaskSectionController
    extends SectionEditorController<ShortTaskItemDto> {
  ShortTaskSectionController({
    required int sectionId,
    required ShortTasksApi api,
  }) : _api = api,
       super(sectionId);

  final ShortTasksApi _api;

  @override
  int idOf(ShortTaskItemDto item) => item.id;

  @override
  Future<SectionData<ShortTaskItemDto>> fetchSection() async {
    final s = await _api.getSection(sectionId: sectionId);
    return (name: s.title, tags: s.tags, items: s.items);
  }

  @override
  Future<void> saveName(String name) =>
      _api.updateSectionTitle(id: sectionId, title: name);

  @override
  Future<void> saveTags(Set<int> ids) => _api.updateSectionTags(
    sectionId: sectionId,
    tagIds: Int64List.fromList(ids.toList()),
  );

  @override
  Future<ShortTaskItemDto> createItemRemote(String text) =>
      _api.createItem(sectionId: sectionId, text: text);

  @override
  Future<void> deleteItemRemote(int id) => _api.deleteItem(id: id);

  @override
  Future<void> deleteSectionRemote() =>
      _api.deleteSection(id: sectionId, force: true);

  ShortTaskItemDto _copy(ShortTaskItemDto i, {String? text, bool? done}) =>
      ShortTaskItemDto(
        id: i.id,
        sectionId: i.sectionId,
        text: text ?? i.text,
        done: done ?? i.done,
      );

  /// Silent (no rebuild): the text field already shows the new text.
  Future<void> updateText(int id, String text) async {
    if (itemById(id) == null) return; // deleted meanwhile
    replaceItem(id, (i) => _copy(i, text: text), notify: false);
    await guard(() => _api.updateItemText(id: id, text: text));
  }

  /// Ticks/unticks right away, then confirms with the core.
  Future<void> toggle(int id) async {
    final item = itemById(id);
    if (item == null) return;
    final nowDone = !item.done;
    replaceItem(id, (i) => _copy(i, done: nowDone));
    try {
      final done = await _api.toggleItemDone(id: id);
      if (done != nowDone) replaceItem(id, (i) => _copy(i, done: done));
    } catch (e) {
      replaceItem(id, (i) => _copy(i, done: !nowDone)); // revert
      report(e);
    }
  }
}
