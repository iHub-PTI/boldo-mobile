part of 'patient_bloc.dart';

@immutable
abstract class PatientState{}

class PatientInitial extends PatientState {}

class PatientLogoutSuccessfully extends PatientState {}

class Failure extends PatientState {
  final String message;
  Failure(this.message);
}