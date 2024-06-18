part of 'doctors_result_bloc.dart';

@immutable
abstract class DoctorsResultEvent {}

class GetDoctorsResult extends DoctorsResultEvent {
  GetDoctorsResult({
    required this.names,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
  final List<Organization> organizations;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
}

class SetInitialDoctors extends DoctorsResultEvent {
  SetInitialDoctors({
    required this.doctors,
  });

  final PagList<Doctor> doctors;
}

class GetMoreDoctorsResult extends DoctorsResultEvent {
  GetMoreDoctorsResult({
    required this.names,
    required this.offset,
    required this.specializations,
    required this.virtualAppointment,
    required this.inPersonAppointment,
    required this.organizations,
  });
  final List<Organization> organizations;
  final int offset;
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  final List<String> names;
}
