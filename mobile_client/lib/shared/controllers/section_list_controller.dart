import 'package:mobile_client/shared/controllers/searchable_list_controller.dart';

/// A searchable list of *sections*: adds create
/// and rename on top of [SearchableListController].
abstract class SectionListController<T> extends SearchableListController<T> {
  SectionListController(super.filters);

  String titleOf(T item);

  /// Creates an empty section and returns its id.
  Future<int> createRemote(String title);
  Future<void> renameRemote(int id, String title);

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
}
