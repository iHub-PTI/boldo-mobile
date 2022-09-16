part of 'home_bloc.dart';

@immutable
abstract class HomeState{}

class HomeInitial extends HomeState {}

class PatientLogoutSuccessfully extends HomeState {}

class Loading extends HomeState {}

class Failed extends HomeState {
  final response;
  Failed({required this.response});
}

class Success extends HomeState {}

class ChangeFamily extends HomeState {}

class RedirectNextScreen extends HomeState {}

class RedirectToHome extends HomeState {}

class RedirectBackScreen extends HomeState {}

class AppointmentsLoaded extends HomeState {
  final List<Appointment> appointments;
  AppointmentsLoaded({required this.appointments});
}

class DiagnosticReportsLoaded extends HomeState {
  final List<DiagnosticReport> diagnosticReports;
  DiagnosticReportsLoaded({required this.diagnosticReports});
}