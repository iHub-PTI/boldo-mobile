part of 'patient_bloc.dart';

@immutable
abstract class PatientEvent {}

class ChangeUser extends PatientEvent {
  final String? id;
  ChangeUser({this.id});
}

class ReloadHome extends PatientEvent {}

class LogoutPatientPressed extends PatientEvent {}

class EditProfile extends PatientEvent {
  final Patient editingPatient;
  EditProfile({required this.editingPatient});
}