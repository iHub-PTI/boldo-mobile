part of 'appointment_bloc.dart';

/// State for [AppointmentBloc]
@immutable
abstract class AppointmentState {}

/// Initial state of [AppointmentBloc] pattern
class AppointmentInitial extends AppointmentState {}

/// Represent a loading status to inform that the data is loading
class Loading extends AppointmentState {}

/// Represent a failed status if some event was failed
class Failed extends AppointmentState {
  /// Represent a failed status if some event was failed
  Failed({required this.response});

  /// The error message of response to show at the user
  final String response;
}

/// Represent a success status of [AppointmentBloc]
class AppointmentLoadedState extends AppointmentState {
  /// Represent a success status of [AppointmentBloc]
  AppointmentLoadedState({required this.appointment});

  /// The appointment that was obtained
  final Appointment appointment;
}
