import 'package:flutter/foundation.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/shared/api_guard.dart';

/// Pagination + multi-selection for any list page. Subclasses only say how to
/// fetch one page ([fetchPage]) and how to read an item's id ([idOf]).
abstract class PagedListController<T> extends ChangeNotifier with ApiGuard {
  static const int pageSize = 20;

  List<T> _items = const [];
  final Set<int> _selected = {};
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _disposed = false;
  int _page = 1; // last page fetched
  int _token = 0; // invalidates stale loads

  int idOf(T item);

  /// One page of raw results (search or plain listing, as appropriate).
  Future<List<T>> fetchPage(ListRequestDto req);

  /// Optional client-side narrowing of a fetched page (e.g. a group filter on
  /// top of a search). "Has more" is still decided by the *raw* page size.
  @protected
  List<T> filterPage(List<T> raw) => raw;

  List<T> get items => _items;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;

  // ------------------------------------------------------------ selection
  Set<int> get selectedIds => _selected;
  bool get selecting => _selected.isNotEmpty;

  void toggleSelection(int id) {
    if (!_selected.add(id)) _selected.remove(id);
    notifyListeners();
  }

  void clearSelection() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }

  // -------------------------------------------------------------- loading
  /// Reloads from page 1, or (with [keepPages]) re-fetches as many pages as
  /// were loaded so the scroll position survives.
  Future<void> reload({bool keepPages = false}) async {
    final token = ++_token;
    final pages = keepPages ? _page : 1;
    _loading = true;
    _loadingMore = false;
    notifyListeners();
    try {
      final all = <T>[];
      var hasMore = true;
      var last = 1;
      for (var p = 1; p <= pages && hasMore; p++) {
        final raw = await fetchPage(
          ListRequestDto(currentPage: p, limit: pageSize),
        );
        if (token != _token) return;
        all.addAll(filterPage(raw));
        hasMore = raw.length >= pageSize;
        last = p;
      }
      _items = all;
      _hasMore = hasMore;
      _page = last;
      _selected.removeWhere((id) => !_items.any((i) => idOf(i) == id));
    } catch (e) {
      if (token == _token) {
        _hasMore = false;
        report(e);
      }
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
      final raw = await fetchPage(
        ListRequestDto(currentPage: _page + 1, limit: pageSize),
      );
      if (token != _token) return;
      _page += 1;
      _items = [..._items, ...filterPage(raw)];
      _hasMore = raw.length >= pageSize;
    } catch (e) {
      if (token == _token) {
        _hasMore = false; // no retry loop; pull-to-refresh resets it
        report(e);
      }
    } finally {
      if (token == _token) {
        _loadingMore = false;
        notifyListeners();
      }
    }
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
