part of 'patient_bloc.dart';

@immutable
abstract class PatientEvent {}

class ChangeUser extends PatientEvent {
  final String? id;
  final BuildContext context;
  ChangeUser({this.id, required this.context});
}

class LogoutPatientPressed extends PatientEvent {}