part of 'doctor_bloc.dart';

@immutable
abstract class DoctorEvent {}

class GetAvailability extends DoctorEvent {
  final String id;
  final String startDate;
  final String endDate;
  GetAvailability({required this.id, required this.startDate, required this.endDate});
}

class ReloadHome extends DoctorEvent {}

class GetDoctor extends DoctorEvent {
  final String id;
  GetDoctor({required this.id});
}

class LinkFamily extends DoctorEvent {}

class LogoutPatientPressed extends DoctorEvent {}