part of 'futureAppointments_bloc.dart';

@immutable
abstract class FutureAppointmentsState{}

class FutureAppointmentsInitial extends FutureAppointmentsState {}

class LoadingAppointments extends FutureAppointmentsState {}

class FailedLoadedAppointments extends FutureAppointmentsState {
  final response;
  FailedLoadedAppointments({required this.response});
}

class AppointmentsHomeLoaded extends FutureAppointmentsState {
  final List<Appointment> appointments;
  AppointmentsHomeLoaded({required this.appointments});
}