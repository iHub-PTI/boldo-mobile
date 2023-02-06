part of 'doctors_available_bloc.dart';

@immutable
abstract class DoctorsAvailableEvent {}

class GetDoctorsAvailable extends DoctorsAvailableEvent {
  final int offset;
  final List<Organization> organizations;
  GetDoctorsAvailable({
    required this.offset,
    required this.organizations,
  });
}

class GetMoreDoctorsAvailable extends DoctorsAvailableEvent {
  final int offset;
  final List<Organization> organizations;
  GetMoreDoctorsAvailable({
    required this.offset,
    required this.organizations,
  });
}

class GetDoctorFilter extends DoctorsAvailableEvent {
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  GetDoctorFilter({
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
  GetDoctorFilterInDoctorList({
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
  GetMoreFilterDoctor({
    required this.offset,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations
  });
}

class ReloadDoctorsAvailable extends DoctorsAvailableEvent {}
