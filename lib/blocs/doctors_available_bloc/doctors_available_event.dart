part of 'doctors_available_bloc.dart';

@immutable
abstract class DoctorsAvailableEvent {}


class GetDoctorFilter extends DoctorsAvailableEvent {
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
  GetDoctorFilter({
    required this.names,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
}

class GetDoctorFilterInDoctorList extends DoctorsAvailableEvent {
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
  GetDoctorFilterInDoctorList({
    required this.names,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
}

class GetMoreFilterDoctor extends DoctorsAvailableEvent {
  final List<Organization> organizations;
  final int offset;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
  GetMoreFilterDoctor({
    required this.names,
    required this.offset,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations
  });
}

class ReloadDoctorsAvailable extends DoctorsAvailableEvent {}
