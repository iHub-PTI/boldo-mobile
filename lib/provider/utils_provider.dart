import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UtilsProvider with ChangeNotifier {
  int _selectedPageIndex = 0;

  int get getSelectedPageIndex => _selectedPageIndex;

  void setSelectedPageIndex({int pageIndex}) {
    _selectedPageIndex = pageIndex;

    notifyListeners();
  }
}
