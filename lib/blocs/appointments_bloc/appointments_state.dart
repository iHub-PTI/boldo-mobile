part of 'appointments_bloc.dart';

/// State for [AppointmentsBloc]
@immutable
abstract class AppointmentsState {}

/// Initial state
class AppointmentsInitial extends AppointmentsState {}

/// Loading state
class Loading extends AppointmentsState {}

/// Failed status with his respective message
class Failed extends AppointmentsState {
  /// Falied status with message to show to te user
  Failed({required this.response});

  /// Failed string message
  final String response;
}

/// Status to emit a list of appointments loaded
class AppointmentsLoadedState extends AppointmentsState {
  /// Status to emit a list of appointments loaded
  AppointmentsLoadedState({required this.appointments});

  /// List of appointments
  final List<Appointment> appointments;
}
