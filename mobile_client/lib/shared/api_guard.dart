import 'package:mobile_client/core/rust/error.dart';

/// Shared error handling for controllers that call the Rust core.
/// Pages set [onError].
mixin ApiGuard {
  void Function(String message)? onError;

  void report(Object e) =>
      onError?.call(e is ApiError ? e.message : e.toString());

  /// Runs [action]; reports any error and returns whether it succeeded.
  Future<bool> guard(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (e) {
      report(e);
      return false;
    }
  }
}
