part of 'doctors_available_bloc.dart';

@immutable
abstract class DoctorsAvailableEvent {}

class GetDoctorsAvailable extends DoctorsAvailableEvent {
  final int offset;
  GetDoctorsAvailable({required this.offset});
}

class GetMoreDoctorsAvailable extends DoctorsAvailableEvent {
  final int offset;
  GetMoreDoctorsAvailable({required this.offset});
}

class GetDoctorFilter extends DoctorsAvailableEvent {
  final List<Specializations> specializations;
  final bool virtualAppointment;
  final bool inPersonAppointment;
  GetDoctorFilter(
      {required this.specializations,
      required this.virtualAppointment,
      required this.inPersonAppointment});
}

class GetSpecializations extends DoctorsAvailableEvent {}

class ReloadDoctorsAvailable extends DoctorsAvailableEvent {}
