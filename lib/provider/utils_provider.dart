import 'package:boldo/models/Specialization.dart';
import 'package:flutter/material.dart';

class UtilsProvider with ChangeNotifier {
  List<Specialization> _selectedSpecializations = [];
  List<String> _selectedLanguages = [];
  String _filterText = "";
  int _selectedPageIndex = 0;
  bool isAppoinmentOnline = false;
  bool isAppoinmentInPerson = false;
  int get getSelectedPageIndex => _selectedPageIndex;
  List<Specialization> get getListOfSpecializations => _selectedSpecializations;
  List<String> get getListOfLanguages => _selectedLanguages;
  int _filterCounter = -1;
  bool get getFilterState =>
      _selectedLanguages.isNotEmpty ||
      _selectedSpecializations.isNotEmpty ||
      isAppoinmentOnline ||
      isAppoinmentInPerson;
  String get getFilterText => _filterText;
  int get getFilterCounter => _filterCounter;

  void setFilterText(String filterText) {
    _filterText = filterText;
  }

  void setSelectedPageIndex({required int pageIndex}) {
    _selectedPageIndex = pageIndex;

    notifyListeners();
  }

  void clearText() {
    _filterText = "";
  }

  void setListOfSpecializations(
      {required List<Specialization> selectedFilters}) {
    _selectedSpecializations = selectedFilters;
    notifyListeners();
  }

  void removeSpecialization({required String specializationId}) {
    _selectedSpecializations = _selectedSpecializations
        .where((element) => element.id != specializationId)
        .toList();
    notifyListeners();
  }

  void addLanguageValue(String languageValue) {
    _selectedLanguages = [..._selectedLanguages, languageValue];
    notifyListeners();
  }

  void setVirtualRemoteStatus(bool isInPerson, bool isOnline) {
    isAppoinmentOnline = isOnline;
    isAppoinmentInPerson = isInPerson;
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
    isAppoinmentOnline = false;
    isAppoinmentInPerson = false;
    _filterCounter = -1;
    notifyListeners();
  }

}
