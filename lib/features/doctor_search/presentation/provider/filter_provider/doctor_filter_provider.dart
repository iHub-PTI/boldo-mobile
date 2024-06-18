import 'package:boldo/features/doctor_search/doctor_search.dart';
import 'package:boldo/models/Doctor.dart';
import 'package:boldo/models/Organization.dart';
import 'package:boldo/models/PagList.dart';
import 'package:boldo/models/filters/DoctorFilter.dart';
import 'package:boldo/utils/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorFilterProvider with ChangeNotifier {
  // this is a list of specializations was selected in filter
  List<Specializations> _selectedSpecializations = [];

  // this is a list of organizations was selected in filter
  List<Organization> _selectedOrganizations = [];

  // this is a list of organizations was selected in filter
  List<String> _selectedNames = [];

  PagList<Doctor> _doctorsSaved = PagList();

  /// these are a boolean variables to check the type of appointment
  bool virtualAppointment = false;
  bool inPersonAppointment = false;

  // functions to get the variables

  /// get filter state
  bool get getFilterState =>
      virtualAppointment ||
      inPersonAppointment ||
      _selectedSpecializations.isNotEmpty ||
      _selectedOrganizations.isNotEmpty ||
      _selectedNames.isNotEmpty;

  AppointmentType getAppointmentType() {
    if (virtualAppointment && inPersonAppointment) return AppointmentType.Both;
    if (virtualAppointment) return AppointmentType.Virtual;
    if (inPersonAppointment) return AppointmentType.InPerson;
    return AppointmentType.None;
  }

  /// get specializations
  List<Specializations> get getSpecializations => _selectedSpecializations;

  /// get organizations
  List<Organization> get getOrganizations => _selectedOrganizations;

  /// get names
  List<String> get getNames => _selectedNames;

  var _doctorFilter = DoctorFilter(
    specializationsApplied: [],
    organizationsApplied: [],
    selectedNamesApplied: [],
  );

  DoctorFilter get doctorFilter => _doctorFilter;

  ///
  set doctorFilter(DoctorFilter filter) {
    _doctorFilter = filter;

    _selectedNames = filter.getNamesApplied;
    _selectedOrganizations = filter.getOrganizationsApplied;
    _selectedSpecializations = filter.getSpecializationsApplied;
    inPersonAppointment = filter.getLastInPersonAppointmentApplied;
    virtualAppointment = filter.getLastVirtualAppointmentApplied;
  }

  /// get the last specializations applied.
  List<Specializations> get getSpecializationsApplied =>
      _doctorFilter.getSpecializationsApplied;

  /// get the last organizations applied.
  List<Organization> get getOrganizationsApplied =>
      _doctorFilter.getOrganizationsApplied;

  /// get the last names applied.
  List<String> get getNamesApplied => _doctorFilter.getNamesApplied;
  bool get getLastVirtualAppointmentApplied =>
      _doctorFilter.getLastVirtualAppointmentApplied;
  bool get getLastInPersonAppointmentApplied =>
      _doctorFilter.getLastInPersonAppointmentApplied;

  /// get doctors
  PagList<Doctor> get getDoctorsSaved => _doctorsSaved;

  /// get true if the appointment is virtual
  bool get getVirtualAppointment => virtualAppointment;

  /// get true if the appointment is in person
  bool get getInPersonAppointment => inPersonAppointment;

  /// add specializations
  void addSpecializations({
    required Specializations specialization,
    required context,
  }) {
    _selectedSpecializations.add(specialization);
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  /// delete specializations
  void removeSpecialization({
    required String specializationId,
    required context,
  }) {
    _selectedSpecializations = _selectedSpecializations
        .where((element) => element.id != specializationId)
        .toList();
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  /// add organization
  void addOrganization({required Organization organization, required context}) {
    _selectedOrganizations.add(organization);
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  /// delete organization
  void removeOrganization({required String organizationId, required context}) {
    _selectedOrganizations = _selectedOrganizations
        .where((element) => element.id != organizationId)
        .toList();
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  /// add organization
  void addName({required String name, required context}) {
    _selectedNames.add(name);
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  /// delete organization
  void removeName({required String name, required context}) {
    _selectedNames =
        _selectedNames.where((element) => element != name).toList();
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  /// delete all specializations
  void removeAllSpecialization() {
    _selectedSpecializations = [];
    notifyListeners();
  }

  /// delete all specializations
  void removeAllOrganization() {
    _selectedOrganizations = [];
    notifyListeners();
  }

  /// delete all names
  void removeAllNames() {
    _selectedNames = [];
    notifyListeners();
  }

  /// delete all specializations
  void clearFilter() {
    _selectedSpecializations = [];
    _selectedOrganizations = [];
    _selectedNames = [];
    inPersonAppointment = false;
    virtualAppointment = false;
    _doctorFilter.clearFilter();
    //notifyListeners();
  }

  void setSpecializations({
    required List<Specializations> specializationsSelectedCopy,
    required context,
  }) {
    _selectedSpecializations = specializationsSelectedCopy;
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  /// set true or false the virtual appointment
  void setVirtualAppointment({required context}) {
    virtualAppointment = !virtualAppointment;
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  /// set true or false the in person appointment
  void setInPersonAppointment({required context}) {
    inPersonAppointment = !inPersonAppointment;
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  void removeAppointmentType({required context}) {
    inPersonAppointment = false;
    virtualAppointment = false;
    // call bloc event
    BlocProvider.of<DoctorFilterBloc>(context).add(
      GetDoctorsPreview(
        organizations: _selectedOrganizations,
        specializations: _selectedSpecializations,
        virtualAppointment: virtualAppointment,
        inPersonAppointment: inPersonAppointment,
        names: _selectedNames,
      ),
    );
    notifyListeners();
  }

  void setDoctors({required PagList<Doctor> doctors}) {
    _doctorsSaved = doctors;
    notifyListeners();
  }

  void filterApplied({
    required List<Specializations> specializationsApplied,
    required bool virtualAppointmentApplied,
    required bool inPersonAppointmentApplied,
    required List<Organization> organizationsApplied,
    required List<String> namesApplied,
  }) {
    doctorFilter = DoctorFilter(
      specializationsApplied: specializationsApplied,
      organizationsApplied: organizationsApplied,
      selectedNamesApplied: namesApplied,
      inPersonAppointmentApplied: inPersonAppointmentApplied,
      virtualAppointmentApplied: virtualAppointment,
    );
    notifyListeners();
  }
}
