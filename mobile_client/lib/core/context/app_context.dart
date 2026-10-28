import 'package:flutter/foundation.dart';

class AppContext extends ChangeNotifier {
  bool _isAuthenticated = false;
  List<String>? _userRoles;

  bool get isAuthenticated => _isAuthenticated;
  List<String>? get userRoles => _userRoles;

  void setAuthStatus(bool status, {List<String>? roles}) {
    _isAuthenticated = status;
    _userRoles = roles;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userRoles = null;
    notifyListeners();
  }
}
