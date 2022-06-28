part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class ReloadHome extends HomeEvent {}

class GetAppointments extends HomeEvent {}

class GetDiagnosticReports extends HomeEvent {}

class LogoutPatientPressed extends HomeEvent {}
