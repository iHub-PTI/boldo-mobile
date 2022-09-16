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
  final List<Appointment> appointments;
  AppointmentLoadedState({required this.appointments});
}

class RedirectNextScreen extends AppointmentState {}

class Success extends AppointmentState {}
