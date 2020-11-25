import 'package:boldo/models/Specialization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UtilsProvider with ChangeNotifier {
  List<Specialization> _selectedSpecializations = [];
  List<String> _selectedLanguages = [];

  int _selectedPageIndex = 0;

  int get getSelectedPageIndex => _selectedPageIndex;
  List<Specialization> get getListOfSpecializations => _selectedSpecializations;
  List<String> get getListOfLanguages => _selectedLanguages;
  bool get getFilterState =>
      _selectedLanguages.isNotEmpty || _selectedSpecializations.isNotEmpty;

  void setSelectedPageIndex({int pageIndex}) {
    _selectedPageIndex = pageIndex;

    notifyListeners();
  }

  void setListOfSpecializations({List<Specialization> selectedFilters}) {
    _selectedSpecializations = selectedFilters;

    notifyListeners();
  }

  void removeSpecialization({String specializationId}) {
    _selectedSpecializations = _selectedSpecializations
        .where((element) => element.id != specializationId)
        .toList();

    notifyListeners();
  }

  void addLanguageValue(String languageValue) {
    _selectedLanguages = [..._selectedLanguages, languageValue];

    notifyListeners();
  }

  void removeLanguageValue(String languageValue) {
    _selectedLanguages =
        _selectedLanguages.where((e) => e != languageValue).toList();

    notifyListeners();
  }

  void clearFilters() {
    _selectedLanguages = [];
    _selectedSpecializations = [];

    notifyListeners();
  }
}
