part of 'doctor_bloc.dart';

@immutable
abstract class DoctorEvent {}

class ChangeUser extends DoctorEvent {
  final String? id;
  ChangeUser({this.id});
}

class ReloadHome extends DoctorEvent {}

class ValidateQr extends DoctorEvent {
  final String id;
  ValidateQr({required this.id});
}

class LinkFamily extends DoctorEvent {}

class LogoutPatientPressed extends DoctorEvent {}