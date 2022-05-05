part of 'patient_bloc.dart';

@immutable
abstract class PatientState{}

class PatientInitial extends PatientState {}

class PatientLogoutSuccessfully extends PatientState {}


class Loading extends PatientState {}

class Failed extends PatientState {
  final response;
  Failed({required this.response});
}

class Success extends PatientState {}

class RedirectToHome extends PatientState {}