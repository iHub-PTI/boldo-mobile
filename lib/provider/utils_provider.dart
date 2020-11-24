import 'package:boldo/models/Specialization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UtilsProvider with ChangeNotifier {
  List<Specialization> _selectedFilters = [];
  int _selectedPageIndex = 0;

  int get getSelectedPageIndex => _selectedPageIndex;
  List<Specialization> get getListOfSpecializations => _selectedFilters;

  void setSelectedPageIndex({int pageIndex}) {
    _selectedPageIndex = pageIndex;

    notifyListeners();
  }

  void setListOfSpecializations({List<Specialization> selectedFilters}) {
    _selectedFilters = selectedFilters;

    notifyListeners();
  }

  void removeSpecialization({String specializationId}) {
    _selectedFilters = _selectedFilters
        .where((element) => element.id != specializationId)
        .toList();

    notifyListeners();
  }
}
