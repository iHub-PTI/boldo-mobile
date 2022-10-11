import 'package:boldo/blocs/doctors_available_bloc/doctors_available_bloc.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorFilterProvider with ChangeNotifier {
  // this is a list of specializations was selected in filter
  List<Specializations> _selectedSpecializations = [];
  List<Doctor> _doctorsSaved = [];
  // these are a boolean variables to check the type of appointment
  bool virtualAppointment = false;
  bool inPersonAppointment = false;
  // first time in filter
  bool firstTime = true;

  // functions to get the variables

  // get filter state
  bool get getFilterState =>
      virtualAppointment ||
      inPersonAppointment ||
      _selectedSpecializations.isNotEmpty;

  // get specializations
  List<Specializations> get getSpecializations => _selectedSpecializations;

  // get doctors
  List<Doctor> get getDoctorsSaved => _doctorsSaved;

  // get if first time in filter
  bool get getFirstTime => firstTime;

  // get true if the appointment is virtual
  bool get getVirtualAppointment => virtualAppointment;

  // get true if the appointment is in person
  bool get getInPersonAppointment => inPersonAppointment;

  // add specializations
  void addSpecializations(
      {required Specializations specialization, required context}) {
    _selectedSpecializations.add(specialization);
    firstTime = false;
    // call bloc event
    BlocProvider.of<DoctorsAvailableBloc>(context).add(GetDoctorFilter(
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment));
    notifyListeners();
  }

  // delete specializations
  void removeSpecialization(
      {required String specializationId, required context}) {
    _selectedSpecializations = _selectedSpecializations
        .where((element) => element.id != specializationId)
        .toList();
    if (_selectedSpecializations.length == 0 &&
        !virtualAppointment &&
        !inPersonAppointment) {
      firstTime = true;
      BlocProvider.of<DoctorsAvailableBloc>(context)
          .add(ReloadDoctorsAvailable());
    } else {
      // if virtualAppointment and inPersonAppointment are not checked then the event should not be called
      firstTime = false;
      // call bloc event
      BlocProvider.of<DoctorsAvailableBloc>(context).add(GetDoctorFilter(
          specializations: _selectedSpecializations,
          virtualAppointment: virtualAppointment,
          inPersonAppointment: inPersonAppointment));
    }
    notifyListeners();
  }

  void setSpecializations(
      {required List<Specializations> specializationsSelectedCopy,
      required context}) {
    _selectedSpecializations = specializationsSelectedCopy;
    if (_selectedSpecializations.isEmpty &&
        !virtualAppointment &&
        !inPersonAppointment) {
      firstTime = true;
      BlocProvider.of<DoctorsAvailableBloc>(context)
          .add(ReloadDoctorsAvailable());
    } else {
      firstTime = false;
      // call bloc event
      BlocProvider.of<DoctorsAvailableBloc>(context).add(GetDoctorFilter(
          specializations: _selectedSpecializations,
          virtualAppointment: virtualAppointment,
          inPersonAppointment: inPersonAppointment));
    }
    notifyListeners();
  }

  void setSpecializationsWithoutEvent(
      {required List<Specializations> specializationsSelected}) {
    _selectedSpecializations = specializationsSelected;
  }

  // set true or false the virtual appointment
  void setVirtualAppointment({required context}) {
    virtualAppointment = !virtualAppointment;
    if (_selectedSpecializations.length == 0 &&
        !virtualAppointment &&
        !inPersonAppointment) {
      firstTime = true;
      BlocProvider.of<DoctorsAvailableBloc>(context)
          .add(ReloadDoctorsAvailable());
    } else {
      firstTime = false;
      // call bloc event
      BlocProvider.of<DoctorsAvailableBloc>(context).add(GetDoctorFilter(
          specializations: _selectedSpecializations,
          virtualAppointment: virtualAppointment,
          inPersonAppointment: inPersonAppointment));
    }

    notifyListeners();
  }

  // set true or false the in person appointment
  void setInPersonAppointment({required context}) {
    inPersonAppointment = !inPersonAppointment;
    if (_selectedSpecializations.length == 0 &&
        !virtualAppointment &&
        !inPersonAppointment) {
      firstTime = true;
      BlocProvider.of<DoctorsAvailableBloc>(context)
          .add(ReloadDoctorsAvailable());
    } else {
      firstTime = false;
      // call bloc event
      BlocProvider.of<DoctorsAvailableBloc>(context).add(GetDoctorFilter(
          specializations: _selectedSpecializations,
          virtualAppointment: virtualAppointment,
          inPersonAppointment: inPersonAppointment));
    }
    notifyListeners();
  }

  void setDoctors({required List<Doctor> doctors}) {
    _doctorsSaved = doctors;
    notifyListeners();
  }
}
