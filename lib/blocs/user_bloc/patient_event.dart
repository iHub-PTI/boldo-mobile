part of 'patient_bloc.dart';

@immutable
abstract class PatientEvent {}

class ChangePatient extends PatientEvent {}

class LogoutPatientPressed extends PatientEvent {}