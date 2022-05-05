part of 'patient_bloc.dart';

@immutable
abstract class PatientEvent {}

class ChangeUser extends PatientEvent {
  final String? id;
  ChangeUser({this.id});
}

class ValidateQr extends PatientEvent {
  final String id;
  ValidateQr({required this.id});
}

class LogoutPatientPressed extends PatientEvent {}