import 'package:flutter/foundation.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/shared/utils/api_guard.dart';

typedef SectionData<I> = ({String name, List<TagDto> tags, List<I> items});

/// One open section (thoughts, checklists, ...): name, tags and items. Edits
/// are applied locally first, then written to the core. Subclasses only map
/// the remote hooks onto their Rust API.
abstract class SectionEditorController<I> extends ChangeNotifier
    with ApiGuard {
  SectionEditorController(this.sectionId);

  final int sectionId;

  bool _loading = true;
  bool _failed = false;
  bool _disposed = false;
  String _name = '';
  List<TagDto> _tags = const [];
  List<I> _items = const [];

  int idOf(I item);
  Future<SectionData<I>> fetchSection();
  Future<void> saveName(String name);
  Future<void> saveTags(Set<int> ids);
  Future<I> createItemRemote(String text);
  Future<void> deleteItemRemote(int id);
  Future<void> deleteSectionRemote();

  bool get loading => _loading;
  bool get failed => _failed;
  String get name => _name;
  List<TagDto> get tags => _tags;
  List<I> get items => _items;

  Future<void> load() async {
    try {
      final d = await fetchSection();
      _name = d.name;
      _tags = [...d.tags];
      _items = [...d.items];
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
    final ok = await guard(() => saveName(value));
    if (ok) _name = value;
  }

  /// Replaces the section's tags with exactly [ids] ([all] resolves the dtos).
  Future<void> setTags(Set<int> ids, List<TagDto> all) async {
    final ok = await guard(() => saveTags(ids));
    if (!ok) return;
    _tags = all.where((t) => ids.contains(t.id)).toList();
    notifyListeners();
  }

  Future<void> addItem(String text) async {
    await guard(() async {
      final item = await createItemRemote(text.trim());
      _items = [..._items, item];
    });
    notifyListeners();
  }

  Future<void> deleteItem(int id) async {
    if (!_items.any((e) => idOf(e) == id)) return;
    _items = _items.where((e) => idOf(e) != id).toList();
    notifyListeners();
    await guard(() => deleteItemRemote(id));
  }

  Future<bool> deleteSection() => guard(deleteSectionRemote);

  // ------------------------------------------------- for subclasses' edits
  @protected
  I? itemById(int id) {
    for (final i in _items) {
      if (idOf(i) == id) return i;
    }
    return null;
  }

  /// Swaps item [id] for `update(item)`. Pass `notify: false` for edits the
  /// UI already shows (e.g. text typed into a field).
  @protected
  void replaceItem(int id, I Function(I item) update, {bool notify = true}) {
    _items = [for (final i in _items) idOf(i) == id ? update(i) : i];
    if (notify) notifyListeners();
  }

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
