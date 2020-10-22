import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  AuthProvider(this._isAuthenticated);

  bool get getAuthenticated => _isAuthenticated;

  void setAuthenticated({bool isAuthenticated}) {
    _isAuthenticated = isAuthenticated;

    notifyListeners();
  }
}
