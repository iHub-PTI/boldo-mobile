part of 'homeAppointments_bloc.dart';

@immutable
abstract class HomeAppointmentsState{}

class HomeAppointmentsInitial extends HomeAppointmentsState {}

class LoadingAppointments extends HomeAppointmentsState {}

class FailedLoadedAppointments extends HomeAppointmentsState {
  final response;
  FailedLoadedAppointments({required this.response});
}

class AppointmentsHomeLoaded extends HomeAppointmentsState {
  final List<Appointment> appointments;
  AppointmentsHomeLoaded({required this.appointments});
}