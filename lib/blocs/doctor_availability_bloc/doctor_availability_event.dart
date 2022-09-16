part of 'doctor_availability_bloc.dart';

@immutable
abstract class DoctorAvailabilityEvent {}

class GetDoctorAvailability extends DoctorAvailabilityEvent {
  final Doctor doctor;
  final DateTime start;
  GetDoctorAvailability({required this.start, required this.doctor});
}

class ReloadHome extends DoctorAvailabilityEvent {}

class ValidateQr extends DoctorAvailabilityEvent {
  final String id;
  ValidateQr({required this.id});
}

class LinkFamily extends DoctorAvailabilityEvent {}

class LogoutPatientPressed extends DoctorAvailabilityEvent {}