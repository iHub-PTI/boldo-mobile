part of 'appointmentBloc.dart';

@immutable
abstract class AppointmentState{}

class AppointmentInitial extends AppointmentState {}

class Loading extends AppointmentState {}

class Failed extends AppointmentState {
  final response;
  Failed({required this.response});
}

class AppointmentLoadedState extends AppointmentState {
  final Appointment appointment;
  AppointmentLoadedState({required this.appointment});
}
