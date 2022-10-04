import 'package:boldo/models/Doctor.dart';
import 'package:flutter/foundation.dart';

class DoctorFilterProvider with ChangeNotifier {
  // this is a list of specializations was selected in filter
  List<Specializations> _selectedSpecializations = [];
  // these are a boolean variables to check the type of appointment
  bool virtualAppointment = false;
  bool inPersonAppointment = false;

  // functions to get the variables

  // get filter state
  bool get getFilterState =>
      virtualAppointment ||
      inPersonAppointment ||
      _selectedSpecializations.isNotEmpty;

  // get specializations
  List<Specializations> get getSpecializations => _selectedSpecializations;

  // add specializations
  void addSpecializations({required Specializations specialization}) {
    _selectedSpecializations.add(specialization);
    // call bloc event

    notifyListeners();
  }

  // delete specializations
  void removeSpecialization({required String specializationId}) {
    _selectedSpecializations = _selectedSpecializations
        .where((element) => element.id != specializationId)
        .toList();
    // call bloc event

    notifyListeners();
  }

  // get true if the appointment is virtual
  bool get getVirtualAppointment => virtualAppointment;

  // set true or false the virtual appointment
  void setVirtualAppointment() {
    virtualAppointment = !virtualAppointment;
    // call bloc event

    notifyListeners();
  }

  // get true if the appointment is in person
  bool get getInPersonAppointment => inPersonAppointment;

  // set true or false the in person appointment
  void setInPersonAppointment() {
    inPersonAppointment = !inPersonAppointment;
    // call bloc event

    notifyListeners();
  }
}
