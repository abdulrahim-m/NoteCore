import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_client/core/rust/api/short_notes.dart';
import 'package:mobile_client/core/rust/dto/short_note.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/shared/utils/api_guard.dart';

/// One open section, its name, tags and thought items. Edits are applied
/// locally first, then written to the core.
class ShortNoteSectionController extends ChangeNotifier with ApiGuard {
  ShortNoteSectionController({required this.sectionId, required ShortNotesApi api})
    : _api = api;

  final int sectionId;
  final ShortNotesApi _api;

  bool _loading = true;
  bool _failed = false;
  bool _disposed = false;
  String _name = '';
  List<TagDto> _tags = [];
  List<ShortNoteItemDto> _items = [];

  bool get loading => _loading;
  bool get failed => _failed;
  String get name => _name;
  List<TagDto> get tags => _tags;
  List<ShortNoteItemDto> get items => _items;

  Future<void> load() async {
    try {
      final s = await _api.getSection(sectionId: sectionId);
      _name = s.name;
      _tags = [...s.tags];
      _items = [...s.items];
    } catch (e) {
      _failed = true;
      report(e);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> rename(String name) async {
    final value = name.trim();
    if (value.isEmpty || value == _name) return;
    final ok = await guard(
      () => _api.updateSectionName(id: sectionId, name: value),
    );
    if (ok) _name = value;
  }

  Future<void> setTags(Set<int> ids, List<TagDto> all) async {
    final ok = await guard(
      () => _api.updateSectionTags(
        sectionId: sectionId,
        tagIds: Int64List.fromList(ids.toList()),
      ),
    );
    if (!ok) return;
    _tags = all.where((t) => ids.contains(t.id)).toList();
    notifyListeners();
  }

  Future<void> addItem(String content) async {
    await guard(() async {
      final item = await _api.createItem(
        sectionId: sectionId,
        content: content.trim(),
      );
      _items = [..._items, item];
    });
    notifyListeners();
  }

  /// Silent, no rebuild.
  Future<void> updateItem(int id, String content) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return; 
    _items[i] = ShortNoteItemDto(id: id, sectionId: sectionId, content: content);
    await guard(() => _api.updateItemContent(id: id, content: content));
  }

  Future<void> deleteItem(int id) async {
    if (!_items.any((e) => e.id == id)) return;
    _items = _items.where((e) => e.id != id).toList();
    notifyListeners();
    await guard(() => _api.deleteItem(id: id));
  }

  Future<bool> deleteSection() =>
      guard(() => _api.deleteSection(id: sectionId, force: true));

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
