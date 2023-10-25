part of 'appointmentsBloc.dart';

@immutable
abstract class AppointmentsState{}

class AppointmentsInitial extends AppointmentsState {}

class Loading extends AppointmentsState {}

class Failed extends AppointmentsState {
  final response;
  Failed({required this.response});
}

class AppointmentsLoadedState extends AppointmentsState {
  final List<Appointment> appointments;
  AppointmentsLoadedState({required this.appointments});
}

class Success extends AppointmentsState {}
