part of 'patient_bloc.dart';

@immutable
abstract class PatientEvent {}

class ChangeUser extends PatientEvent {
  final String? id;
  ChangeUser({this.id});
}

class ReloadHome extends PatientEvent {}

class ValidateQr extends PatientEvent {
  final String id;
  ValidateQr({required this.id});
}

class LinkFamily extends PatientEvent {}

class LogoutPatientPressed extends PatientEvent {}