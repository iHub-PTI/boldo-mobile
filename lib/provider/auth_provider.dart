import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isFamily = false;

  AuthProvider(this._isAuthenticated);

  bool get getAuthenticated => _isAuthenticated;
  bool get getIsFamily => _isFamily;

  void setAuthenticated({required bool isAuthenticated}) {
    _isAuthenticated = isAuthenticated;

    notifyListeners();
  }

  void setIsFamily({required bool isFamily}) {
    _isFamily = isFamily;

    notifyListeners();
  }
}
